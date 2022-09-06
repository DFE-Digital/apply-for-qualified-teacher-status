# frozen_string_literal: true

class AssessorInterface::ApplicationFormsShowViewObject
  def initialize(params:)
    @params = params
  end

  def application_form
    @application_form ||= ApplicationForm.find(params[:id])
  end

  def back_link_path
    url_helpers.assessor_interface_application_forms_path(
      params[:search]&.permit!
    )
  end

  def assessment_tasks
    {
      submitted_details: submitted_details_tasks,
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

  def assessment_task_status(section, _item)
    return :in_progress if section == :submitted_details
    :not_started
  end

  private

  attr_reader :params

  def submitted_details_tasks
    %i[personal_information qualifications].tap do |tasks|
      tasks << :work_history if application_form.needs_work_history?
      if application_form.needs_written_statement? ||
           application_form.needs_registration_number?
        tasks << :professional_standing
      end
    end
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
