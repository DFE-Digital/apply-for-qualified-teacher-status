# frozen_string_literal: true

class ApplicationFormStatusUpdater
  include ServicePattern

  def initialize(application_form:, user:)
    @application_form = application_form
    @user = user
  end

  def call
    ChangeApplicationFormState.call(application_form:, user:, new_state:)
  end

  private

  attr_reader :application_form, :user

  def new_state
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
end
