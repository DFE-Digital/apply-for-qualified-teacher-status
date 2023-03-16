# frozen_string_literal: true

class ApplicationFormStatusUpdater
  include ServicePattern

  def initialize(application_form:, user:)
    @application_form = application_form
    @user = user
  end

  def call
    old_status = application_form.status

    ActiveRecord::Base.transaction do
      application_form.update!(
        waiting_on_further_information:,
        received_further_information:,
        waiting_on_professional_standing:,
        received_professional_standing:,
        waiting_on_qualification:,
        received_qualification:,
        waiting_on_reference:,
        received_reference:,
      )

      next if old_status == new_status

      application_form.update!(status: new_status)
      create_timeline_event(old_state: old_status, new_state: new_status)
    end
  end

  private

  attr_reader :application_form, :user

  def waiting_on_further_information
    waiting_on?(requestables: further_information_requests)
  end

  def received_further_information
    received?(requestables: further_information_requests)
  end

  def waiting_on_professional_standing
    waiting_on?(requestables: professional_standing_requests)
  end

  def received_professional_standing
    received?(requestables: professional_standing_requests)
  end

  def waiting_on_qualification
    waiting_on?(requestables: qualification_requests)
  end

  def received_qualification
    received?(requestables: qualification_requests)
  end

  def waiting_on_reference
    waiting_on?(requestables: reference_requests)
  end

  def received_reference
    received?(requestables: reference_requests)
  end

  def new_status
    @new_status ||=
      if dqt_trn_request&.potential_duplicate?
        "potential_duplicate_in_dqt"
      elsif application_form.declined_at.present?
        "declined"
      elsif application_form.awarded_at.present?
        "awarded"
      elsif dqt_trn_request.present?
        "awarded_pending_checks"
      elsif reviewable_further_information_requests? ||
            reviewable_professional_standing_requests? ||
            reviewable_qualification_requests? || reviewable_reference_requests?
        "received"
      elsif waiting_on_further_information ||
            waiting_on_professional_standing || waiting_on_qualification ||
            (waiting_on_reference && references_verified != true)
        "waiting_on"
      elsif received_further_information ||
            (
              !teaching_authority_provides_written_statement &&
                received_professional_standing
            ) || received_qualification || received_reference
        "received"
      elsif assessment&.started?
        "initial_assessment"
      elsif application_form.submitted_at.present? ||
            (
              teaching_authority_provides_written_statement &&
                received_professional_standing
            )
        "submitted"
      else
        "draft"
      end
  end

  delegate :assessment,
           :dqt_trn_request,
           :region,
           :teacher,
           :teaching_authority_provides_written_statement,
           to: :application_form
  delegate :references_verified, to: :assessment

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

  def waiting_on?(requestables:)
    requestables.any?(&:requested?) || requestables.any?(&:expired?)
  end

  def received?(requestables:)
    requestables.any?(&:received?)
  end

  def reviewable?(requestables:)
    requestables.any? do |requestable|
      requestable.received? && !requestable.reviewed?
    end
  end

  def reviewable_further_information_requests?
    reviewable?(requestables: further_information_requests)
  end

  def reviewable_professional_standing_requests?
    return false if teaching_authority_provides_written_statement
    reviewable?(requestables: professional_standing_requests)
  end

  def reviewable_qualification_requests?
    reviewable?(requestables: qualification_requests)
  end

  def reviewable_reference_requests?
    return false unless reviewable?(requestables: reference_requests)

    received_requests = reference_requests.filter(&:received?)

    months_count =
      WorkHistoryDuration.new(
        work_history_relation:
          application_form.work_histories.where(
            id: received_requests.map(&:work_history_id),
          ),
      ).count_months

    if months_count < 9
      false
    elsif months_count >= 20 &&
          (region.checks_available? || most_recent_reference_request&.received?)
      true
    else
      reference_requests.filter(&:requested?).empty?
    end
  end

  def most_recent_reference_request
    reference_requests.max_by { |request| request.work_history.start_date }
  end

  def create_timeline_event(old_state:, new_state:)
    creator = user.is_a?(String) ? nil : user
    creator_name = user.is_a?(String) ? user : ""

    TimelineEvent.create!(
      application_form:,
      event_type: "state_changed",
      creator:,
      creator_name:,
      new_state:,
      old_state:,
    )
  end
end
