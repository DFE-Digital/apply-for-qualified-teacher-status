# frozen_string_literal: true

class TeacherInterface::ApplicationFormShowViewObject
  def initialize(current_teacher:)
    @current_teacher = current_teacher
  end

  def teacher
    @current_teacher
  end

  def application_form
    @application_form ||= teacher.application_form
  end

  def assessment
    @assessment ||= application_form&.assessment
  end

  def further_information_request
    @further_information_request ||=
      FurtherInformationRequest
        .joins(:assessment)
        .where(assessments: { application_form: })
        .order(:created_at)
        .first
  end

  def declined_cannot_reapply?
    return false if assessment.nil?

    assessment.sections.any? do |section|
      section.selected_failure_reasons.any? do |key, _|
        %w[authorisation_to_teach applicant_already_qts].include?(key)
      end
    end
  end
end
