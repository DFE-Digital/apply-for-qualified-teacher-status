# frozen_string_literal: true

class TeacherInterface::ApplicationFormShowViewObject
  def initialize(current_teacher:)
    @current_teacher = current_teacher
  end

  def application_form
    @application_form ||= current_teacher.application_form
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

  private

  attr_reader :current_teacher
end
