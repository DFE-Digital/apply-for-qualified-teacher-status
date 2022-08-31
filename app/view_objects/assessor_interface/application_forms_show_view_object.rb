# frozen_string_literal: true

class AssessorInterface::ApplicationFormsShowViewObject
  def initialize(params:)
    @params = params
  end

  def application_form
    @application_form ||= ApplicationForm.find(params[:id])
  end

  def back_link_path
    Rails
      .application
      .routes
      .url_helpers
      .assessor_interface_application_forms_path(params[:search]&.permit!)
  end

  def assessment_tasks
    {
      submitted_details: %i[
        personal_information
        qualifications
        work_history
        professional_standing
      ],
      recommendation: %i[first_assessment second_assessment]
    }
  end

  def assessment_task_path(_section, _item)
    "#"
  end

  def assessment_task_status(section, _item)
    return :in_progress if section == :submitted_details
    :not_started
  end

  attr_reader :params
end
