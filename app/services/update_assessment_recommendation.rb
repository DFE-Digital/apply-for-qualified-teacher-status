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

      send_decline_email if assessment.decline?

      CreateDQTTRNRequest.call(application_form:) if assessment.award?

      true
    end
  end

  private

  attr_reader :assessment, :user, :new_recommendation

  delegate :application_form, to: :assessment
  delegate :teacher, to: :application_form

  def new_application_form_state
    return "awarded_pending_checks" if assessment.award?
    return "declined" if assessment.decline?
    nil
  end

  def send_decline_email
    TeacherMailer.with(teacher:).application_declined.deliver_later
  end
end
