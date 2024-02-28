# frozen_string_literal: true

class ApplicationFormStatusUpdater
  include ServicePattern

  def initialize(application_form:, user:)
    @application_form = application_form
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      if (old_action_required_by = application_form.action_required_by) !=
           action_required_by
        application_form.action_required_by = action_required_by
        CreateTimelineEvent.call(
          "action_required_by_changed",
          application_form:,
          user:,
          old_value: old_action_required_by,
          new_value: action_required_by,
        )
      end

      if (old_stage = application_form.stage) != stage
        application_form.stage = stage
        CreateTimelineEvent.call(
          "stage_changed",
          application_form:,
          user:,
          old_value: old_stage,
          new_value: stage,
        )
      end

      if statuses != application_form.statuses
        application_form.statuses = statuses
      end

      application_form.save! if application_form.changed?
    end
  end

  private

  attr_reader :application_form, :user

  def action_required_by
    @action_required_by ||=
      if application_form.withdrawn_at.present? ||
           application_form.declined_at.present? ||
           application_form.awarded_at.present?
        "none"
      elsif dqt_trn_request.present? || assessment_in_review? ||
            overdue_further_information || overdue_ecctis ||
            received_further_information || received_ecctis
        "assessor"
      elsif preliminary_check? || need_to_request_lops? ||
            need_to_request_consent? || need_to_request_ecctis? ||
            overdue_consent || received_consent || overdue_lops ||
            received_lops || overdue_reference || received_reference
        "admin"
      elsif waiting_on_consent || waiting_on_further_information ||
            waiting_on_lops || waiting_on_ecctis || waiting_on_reference
        "external"
      elsif application_form.submitted_at.present?
        "assessor"
      else
        "none"
      end
  end

  def stage
    @stage ||=
      if application_form.withdrawn_at.present? ||
           application_form.declined_at.present? ||
           application_form.awarded_at.present?
        "completed"
      elsif assessment_in_review? || dqt_trn_request.present?
        "review"
      elsif preliminary_check? ||
            (teaching_authority_provides_written_statement && waiting_on_lops)
        "pre_assessment"
      elsif assessment_in_verify? || need_to_request_lops? ||
            need_to_request_consent? || need_to_request_ecctis? ||
            overdue_consent || overdue_lops || overdue_ecctis ||
            overdue_reference || received_consent || received_lops ||
            received_ecctis || received_reference || waiting_on_consent ||
            waiting_on_lops || waiting_on_ecctis || waiting_on_reference
        "verification"
      elsif overdue_further_information || received_further_information ||
            waiting_on_further_information ||
            assessment&.any_not_preliminary_section_finished?
        "assessment"
      elsif application_form.submitted_at.present?
        "not_started"
      else
        "draft"
      end
  end

  def statuses
    @statuses ||=
      if application_form.withdrawn_at.present?
        %w[withdrawn]
      elsif application_form.declined_at.present?
        %w[declined]
      elsif application_form.awarded_at.present?
        %w[awarded]
      elsif dqt_trn_request.present?
        if dqt_trn_request.potential_duplicate?
          %w[potential_duplicate_in_dqt]
        else
          %w[awarded_pending_checks]
        end
      elsif assessment.present?
        if preliminary_check?
          %w[preliminary_check] + requestable_statuses
        elsif assessment_in_review?
          %w[review]
        elsif requestable_statuses.present?
          requestable_statuses
        elsif assessment_in_verify?
          %w[verification_in_progress]
        elsif assessment.any_not_preliminary_section_finished?
          %w[assessment_in_progress]
        else
          %w[assessment_not_started]
        end
      else
        %w[draft]
      end
  end

  delegate :assessment,
           :dqt_trn_request,
           :region,
           :teacher,
           :teaching_authority_provides_written_statement,
           to: :application_form

  def preliminary_check?
    return false if assessment.nil?

    application_form.requires_preliminary_check &&
      (
        assessment.any_preliminary_section_failed? ||
          !assessment.all_preliminary_sections_passed?
      )
  end

  def assessment_in_review?
    assessment&.review? || false
  end

  def assessment_in_verify?
    assessment&.verify? || false
  end

  def need_to_request_lops?
    return false if teaching_authority_provides_written_statement

    professional_standing_requests.any?(&:not_requested?)
  end

  def need_to_request_consent?
    qualification_requests.any?(&:consent_method_unknown?) ||
      consent_requests.any?(&:not_requested?)
  end

  def need_to_request_ecctis?
    qualification_requests
      .select(&:not_requested?)
      .any? do |qualification_request|
        qualification_request.consent_method_unsigned? ||
          consent_requests
            .select(&:verify_passed?)
            .any? do |consent_request|
              consent_request.qualification ==
                qualification_request.qualification
            end
      end
  end

  def requestable_statuses
    @requestable_statuses ||=
      %w[overdue received waiting_on]
        .product(%w[consent ecctis further_information lops reference])
        .map { |status, requestable| "#{status}_#{requestable}" }
        .filter { |column| send(column) }
  end

  def overdue_consent
    overdue?(requestables: consent_requests)
  end

  def overdue_further_information
    overdue?(requestables: further_information_requests)
  end

  def overdue_lops
    return false if teaching_authority_provides_written_statement
    overdue?(requestables: professional_standing_requests)
  end

  def overdue_ecctis
    overdue?(requestables: qualification_requests)
  end

  def overdue_reference
    overdue?(requestables: reference_requests)
  end

  def received_consent
    received?(requestables: consent_requests)
  end

  def received_further_information
    received?(requestables: further_information_requests)
  end

  def received_lops
    return false if teaching_authority_provides_written_statement
    received?(requestables: professional_standing_requests)
  end

  def received_ecctis
    received?(requestables: qualification_requests)
  end

  def received_reference
    return false unless received?(requestables: reference_requests)

    received_requests = reference_requests.filter(&:received?)

    work_history_duration =
      WorkHistoryDuration.for_ids(
        received_requests.map(&:work_history_id),
        application_form:,
      )

    most_recent_reference_request =
      reference_requests.max_by { |request| request.work_history.start_date }

    if !work_history_duration.enough_for_submission?
      false
    elsif work_history_duration.enough_to_skip_induction? &&
          (region.checks_available? || most_recent_reference_request&.received?)
      true
    else
      reference_requests.all? { |r| r.received? || r.expired? }
    end
  end

  def waiting_on_consent
    waiting_on?(requestables: consent_requests)
  end

  def waiting_on_further_information
    waiting_on?(requestables: further_information_requests)
  end

  def waiting_on_lops
    waiting_on?(requestables: professional_standing_requests)
  end

  def waiting_on_ecctis
    waiting_on?(requestables: qualification_requests)
  end

  def waiting_on_reference
    waiting_on?(requestables: reference_requests)
  end

  def consent_requests
    @consent_requests ||= assessment&.consent_requests.to_a
  end

  def further_information_requests
    @further_information_requests ||=
      assessment&.further_information_requests.to_a
  end

  def professional_standing_requests
    @professional_standing_requests ||= [
      assessment&.professional_standing_request,
    ].compact
  end

  def qualification_requests
    @qualification_requests ||= assessment&.qualification_requests.to_a
  end

  def reference_requests
    @reference_requests ||= assessment&.reference_requests.to_a
  end

  def overdue?(requestables:)
    requestables.reject(&:verified?).reject(&:reviewed?).any?(&:expired?)
  end

  def waiting_on?(requestables:)
    requestables
      .reject(&:verified?)
      .reject(&:reviewed?)
      .reject(&:expired?)
      .reject(&:received?)
      .any?(&:requested?)
  end

  def received?(requestables:)
    requestables
      .reject(&:verified?)
      .reject(&:reviewed?)
      .reject(&:expired?)
      .any?(&:received?)
  end
end
