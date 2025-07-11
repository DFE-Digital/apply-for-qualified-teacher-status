# frozen_string_literal: true

class PrioritiseAssessment
  include ServicePattern

  def initialize(assessment:, user:)
    @assessment = assessment
    @user = user
  end

  def call
    raise InvalidState unless assessment.can_prioritise?

    assessment.update!(
      prioritisation_decision_at: Time.current,
      prioritised: true,
    )

    if request_professional_standing?
      RequestRequestable.call(requestable: professional_standing_request, user:)
    else
      DeliverEmail.call(
        application_form:,
        mailer: TeacherMailer,
        action: :application_prioritised,
      )
    end

    ApplicationFormStatusUpdater.call(application_form:, user:)
  end

  class InvalidState < StandardError
  end

  private

  attr_reader :assessment, :user

  def request_professional_standing?
    professional_standing_request.present? &&
      !professional_standing_request.requested?
  end

  def professional_standing_request
    @professional_standing_request ||= assessment.professional_standing_request
  end

  delegate :application_form, to: :assessment
end
