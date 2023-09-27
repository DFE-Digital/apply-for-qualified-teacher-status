# frozen_string_literal: true

class ApplicationFormStatusUpdater
  include ServicePattern

  def initialize(application_form:, user:)
    @application_form = application_form
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      application_form.update!(
        overdue_further_information:,
        overdue_professional_standing:,
        overdue_qualification:,
        overdue_reference:,
        received_further_information:,
        received_professional_standing:,
        received_qualification:,
        received_reference:,
        waiting_on_further_information:,
        waiting_on_professional_standing:,
        waiting_on_qualification:,
        waiting_on_reference:,
      )

      if (old_status = application_form.status) != status
        application_form.update!(status:)
        create_timeline_event(
          event_type: "state_changed",
          old_state: old_status,
          new_state: status,
        )
      end

      if (old_action_required_by = application_form.action_required_by) !=
           action_required_by
        application_form.update!(action_required_by:)
        create_timeline_event(
          event_type: "action_required_by_changed",
          old_value: old_action_required_by,
          new_value: action_required_by,
        )
      end
    end
  end

  private

  attr_reader :application_form, :user

  def overdue_further_information
    overdue?(requestables: further_information_requests)
  end

  def overdue_professional_standing
    return false if teaching_authority_provides_written_statement
    overdue?(requestables: professional_standing_requests)
  end

  def overdue_qualification
    overdue?(requestables: qualification_requests)
  end

  def overdue_reference
    return false if references_verified
    overdue?(requestables: reference_requests)
  end

  def received_further_information
    received?(requestables: further_information_requests)
  end

  def received_professional_standing
    return false if teaching_authority_provides_written_statement

    professional_standing_requests
      .reject(&:reviewed?)
      .any? do |requestable|
        requestable.received? || requestable.ready_for_review
      end
  end

  def received_qualification
    received?(requestables: qualification_requests)
  end

  def received_reference
    return false unless received?(requestables: reference_requests)

    received_requests = reference_requests.filter(&:received?)

    months_count =
      WorkHistoryDuration.new(
        work_history_relation:
          application_form.work_histories.where(
            id: received_requests.map(&:work_history_id),
          ),
      ).count_months

    most_recent_reference_request =
      reference_requests.max_by { |request| request.work_history.start_date }

    if months_count < 9
      false
    elsif months_count >= 20 &&
          (region.checks_available? || most_recent_reference_request&.received?)
      true
    else
      reference_requests.filter(&:requested?).empty?
    end
  end

  def waiting_on_further_information
    waiting_on?(requestables: further_information_requests)
  end

  def waiting_on_professional_standing
    waiting_on?(requestables: professional_standing_requests)
  end

  def waiting_on_qualification
    waiting_on?(requestables: qualification_requests)
  end

  def waiting_on_reference
    return false if references_verified
    waiting_on?(requestables: reference_requests)
  end

  def status
    @status ||=
      if dqt_trn_request&.potential_duplicate?
        "potential_duplicate_in_dqt"
      elsif application_form.withdrawn_at.present?
        "withdrawn"
      elsif application_form.declined_at.present?
        "declined"
      elsif application_form.awarded_at.present?
        "awarded"
      elsif dqt_trn_request.present?
        "awarded_pending_checks"
      elsif preliminary_check?
        "preliminary_check"
      elsif overdue_further_information || overdue_professional_standing ||
            overdue_qualification || overdue_reference
        "overdue"
      elsif received_further_information || received_professional_standing ||
            received_qualification || received_reference
        "received"
      elsif waiting_on_further_information ||
            waiting_on_professional_standing || waiting_on_qualification ||
            waiting_on_reference
        "waiting_on"
      elsif assessment&.any_not_preliminary_section_finished?
        "assessment_in_progress"
      elsif application_form.submitted_at.present?
        "submitted"
      else
        "draft"
      end
  end

  def action_required_by
    @action_required_by ||=
      if status == "preliminary_check"
        "admin"
      elsif %w[
            potential_duplicate_in_dqt
            awarded_pending_checks
            overdue
            received
            assessment_in_progress
            submitted
          ].include?(status)
        "assessor"
      elsif status == "waiting_on"
        "external"
      else
        "none"
      end
  end

  delegate :assessment,
           :dqt_trn_request,
           :region,
           :teacher,
           :teaching_authority_provides_written_statement,
           to: :application_form
  delegate :references_verified, to: :assessment, allow_nil: true

  def preliminary_check?
    application_form.submitted_at.present? &&
      application_form.requires_preliminary_check &&
      (
        assessment&.any_preliminary_section_failed? ||
          !assessment&.all_preliminary_sections_passed?
      )
  end

  def further_information_requests
    @further_information_requests ||=
      assessment&.further_information_requests&.to_a || []
  end

  def professional_standing_requests
    @professional_standing_requests ||= [
      assessment&.professional_standing_request,
    ].compact
  end

  def qualification_requests
    @qualification_requests ||= assessment&.qualification_requests&.to_a || []
  end

  def reference_requests
    @reference_requests ||= assessment&.reference_requests&.to_a || []
  end

  def overdue?(requestables:)
    requestables.reject(&:reviewed?).any?(&:expired?)
  end

  def waiting_on?(requestables:)
    requestables.reject(&:reviewed?).any?(&:requested?)
  end

  def received?(requestables:)
    requestables.reject(&:reviewed?).any?(&:received?)
  end

  def create_timeline_event(event_type:, **kwargs)
    creator = user.is_a?(String) ? nil : user
    creator_name = user.is_a?(String) ? user : ""

    TimelineEvent.create!(
      application_form:,
      event_type:,
      creator:,
      creator_name:,
      **kwargs,
    )
  end
end
