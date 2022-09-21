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
      next false unless assessment.update(recommendation: new_recommendation)

      if (new_state = new_application_form_state)
        ChangeApplicationFormState.call(
          application_form: assessment.application_form,
          user:,
          new_state:,
        )
      end

      true
    end
  end

  private

  attr_reader :assessment, :user, :new_recommendation

  def new_application_form_state
    return "awarded" if assessment.award?
    "declined" if assessment.decline?
  end
end
