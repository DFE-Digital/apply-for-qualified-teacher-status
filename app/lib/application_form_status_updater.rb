# frozen_string_literal: true

class ApplicationFormStatusUpdater
  include ServicePattern

  def initialize(application_form:, user:)
    @application_form = application_form
    @user = user
  end

  def call
    return if application_form.state == new_state

    old_state = application_form.state

    ActiveRecord::Base.transaction do
      application_form.update!(state: new_state)
      create_timeline_event(old_state:, new_state:)
    end
  end

  private

  attr_reader :application_form, :user

  def new_state
    @new_state ||=
      if dqt_trn_request&.potential_duplicate?
        "potential_duplicate_in_dqt"
      elsif application_form.declined_at.present?
        "declined"
      elsif application_form.awarded_at.present?
        "awarded"
      elsif dqt_trn_request.present?
        "awarded_pending_checks"
      elsif further_information_request&.received?
        "received"
      elsif further_information_request&.requested?
        "waiting_on"
      elsif assessment&.started?
        "initial_assessment"
      elsif application_form.submitted_at.present?
        "submitted"
      else
        "draft"
      end
  end

  delegate :assessment, :dqt_trn_request, :teacher, to: :application_form

  def further_information_request
    assessment&.further_information_requests&.first
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
