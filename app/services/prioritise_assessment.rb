# frozen_string_literal: true

class PrioritiseAssessment
  include ServicePattern

  def initialize(assessment:, user:)
    @assessment = assessment
    @user = user
  end

  def call
    raise InvalidState unless assessment.can_prioritise?

    ActiveRecord::Base.transaction do
      assessment.update!(
        prioritisation_decision_at: Time.current,
        prioritised: true,
      )

      ApplicationFormStatusUpdater.call(application_form:, user:)
    end

    DeliverEmail.call(
      application_form:,
      mailer: TeacherMailer,
      action: :application_prioritised,
    )
  end

  class InvalidState < StandardError
  end

  private

  attr_reader :assessment, :user

  delegate :application_form, to: :assessment
end
