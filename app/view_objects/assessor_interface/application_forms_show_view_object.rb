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
    assessment_section_keys = assessment.sections.map(&:key).map(&:to_sym)

    submitted_details =
      %i[
        personal_information
        qualifications
        work_history
        professional_standing
      ].select { |key| assessment_section_keys.include?(key) }

    { submitted_details:, recommendation: %i[initial_assessment] }
  end

  def assessment_task_path(section, item)
    case section
    when :submitted_details
      url_helpers.assessor_interface_application_form_assessment_assessment_section_path(
        application_form,
        assessment,
        item
      )
    when :recommendation
      return nil unless assessment.sections_finished?

      url_helpers.edit_assessor_interface_application_form_assessment_path(
        application_form,
        assessment
      )
    end
  end

  def assessment_task_status(section, item)
    case section
    when :submitted_details
      assessment.sections.find { |s| s.key == item.to_s }.state
    when :recommendation
      return :completed if assessment.finished?
      assessment.sections_finished? ? :not_started : :cannot_start_yet
    end
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
