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

      ApplicationFormStatusUpdater.call(application_form:, user:)
    end
  end

  class AlreadyReviewed < StandardError
  end

  private

  attr_reader :assessment, :user

  delegate :application_form, to: :assessment
end
