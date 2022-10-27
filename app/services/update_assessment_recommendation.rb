# frozen_string_literal: true

class UpdateAssessmentRecommendation
  include ServicePattern

  def initialize(assessment:, user:, new_recommendation:)
    @assessment = assessment
    @user = user
    @new_recommendation = new_recommendation
  end

  def call
    return true if assessment.recommendation == new_recommendation

    ActiveRecord::Base.transaction do
      unless assessment.update(
               recommendation: new_recommendation,
               recommended_at: Time.zone.now,
             )
        next false
      end

      if (new_state = new_application_form_state)
        ChangeApplicationFormState.call(application_form:, user:, new_state:)
      end

      if assessment.award?
        CreateDQTTRNRequestJob.perform_later(
          SecureRandom.uuid,
          application_form,
        )
      end

      true
    end
  end

  private

  attr_reader :assessment, :user, :new_recommendation

  delegate :application_form, to: :assessment

  def new_application_form_state
    return "awarded" if assessment.award?
    return "declined" if assessment.decline?
    nil
  end
end
