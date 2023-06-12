# frozen_string_literal: true

class RollbackAssessment
  include ServicePattern

  def initialize(assessment:, user:)
    @assessment = assessment
    @user = user
  end

  def call
    unless assessment.award? || assessment.decline?
      raise RecommendationNotAwardOrDecline
    end

    ActiveRecord::Base.transaction do
      update_assessment
      update_application_form
    end
  end

  private

  attr_reader :assessment, :user

  def update_assessment
    if previously_verified?
      assessment.verify!
    elsif previously_further_information_requested?
      assessment.request_further_information!
    else
      assessment.unknown!
    end
  end

  def previously_verified?
    assessment.reference_requests.exists?
  end

  def previously_further_information_requested?
    assessment.further_information_requests.exists?
  end

  delegate :application_form, to: :assessment

  def update_application_form
    if application_form.awarded?
      application_form.update!(awarded_at: nil)
    elsif application_form.declined?
      application_form.update!(declined_at: nil)
    end

    ApplicationFormStatusUpdater.call(application_form:, user:)
  end

  class RecommendationNotAwardOrDecline < StandardError
  end
end
