# frozen_string_literal: true

class DeprioritiseAssessment
  include ServicePattern

  def initialize(assessment:, user:)
    @assessment = assessment
    @user = user
  end

  def call
    if !assessment.can_update_prioritisation_decision? ||
         assessment.can_prioritise?
      raise InvalidState
    end

    ActiveRecord::Base.transaction do
      assessment.update!(
        prioritisation_decision_at: Time.current,
        prioritised: false,
      )

      if application_form.requires_preliminary_check
        create_preliminary_check_assessment_section
      end

      ApplicationFormStatusUpdater.call(application_form:, user:)
    end

    DeliverEmail.call(
      application_form:,
      mailer: TeacherMailer,
      action: :application_not_prioritised,
    )
  end

  class InvalidState < StandardError
  end

  private

  attr_reader :assessment, :user

  delegate :application_form, to: :assessment

  def create_preliminary_check_assessment_section
    preliminary_assessment_sections =
      PreliminaryAssessmentSectionsFactory.call(application_form:)

    preliminary_assessment_sections.map do |preliminary_assessment_section|
      preliminary_assessment_section.assessment = assessment
      preliminary_assessment_section.save!
    end
  end
end
