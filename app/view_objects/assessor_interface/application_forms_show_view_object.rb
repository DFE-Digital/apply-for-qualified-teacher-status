# frozen_string_literal: true

class AssessorInterface::ApplicationFormsShowViewObject
  def initialize(params:)
    @params = params
  end

  def application_form
    @application_form ||=
      ApplicationForm.includes(assessment: :sections).find(params[:id])
  end

  def back_link_path
    url_helpers.assessor_interface_application_forms_path(
      params[:search]&.permit!
    )
  end

  def assessment_tasks
    {
      submitted_details: assessment.sections.map(&:key).map(&:to_sym),
      recommendation: %i[first_assessment second_assessment]
    }
  end

  def assessment_task_path(section, item)
    case section
    when :submitted_details
      url_helpers.send(
        "assessor_interface_application_form_check_#{item}_path",
        application_form
      )
    when :recommendation
      url_helpers.assessor_interface_application_form_complete_assessment_path(
        application_form
      )
    end
  end

  def assessment_task_status(section, item)
    if section == :submitted_details
      return assessment.sections.find { |s| s.key == item.to_s }.state
    end

    :not_started
  end

  private

  attr_reader :params

  def assessment
    @assessment ||= application_form.assessment
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
