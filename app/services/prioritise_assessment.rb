# frozen_string_literal: true

class PrioritiseAssessment
  include ServicePattern

  def initialize(assessment:, user:)
    @assessment = assessment
    @user = user
    @professional_standing_requested = nil
  end

  def call
    raise InvalidState unless assessment.can_prioritise?

    ActiveRecord::Base.transaction do
      assessment.update!(
        prioritisation_decision_at: Time.current,
        prioritised: true,
      )

      request_professional_standing

      ApplicationFormStatusUpdater.call(application_form:, user:)
    end

    unless professional_standing_requested
      DeliverEmail.call(
        application_form:,
        mailer: TeacherMailer,
        action: :application_prioritised,
      )
    end
  end

  class InvalidState < StandardError
  end

  private

  attr_accessor :professional_standing_requested
  attr_reader :assessment, :user

  def request_professional_standing
    requestable = assessment.professional_standing_request
    return if requestable.nil? || requestable.requested?

    RequestRequestable.call(requestable:, user:)

    @professional_standing_requested = true
  end

  delegate :application_form, to: :assessment
end
