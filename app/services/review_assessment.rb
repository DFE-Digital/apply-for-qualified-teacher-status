# frozen_string_literal: true

class ReviewAssessment
  include ServicePattern

  def initialize(assessment:, user:)
    @assessment = assessment
    @user = user
  end

  def call
    raise AlreadyReviewed if assessment.review?

    ActiveRecord::Base.transaction do
      assessment.review!
      application_form.update!(verifier: user)

      CreateTimelineEvent.call(
        "verification_decision_made",
        application_form:,
        user:,
      )

      ApplicationFormStatusUpdater.call(application_form:, user:)
    end
  end

  class AlreadyReviewed < StandardError
  end

  private

  attr_reader :assessment, :user

  delegate :application_form, to: :assessment
end
