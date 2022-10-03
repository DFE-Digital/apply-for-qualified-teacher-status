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
      params[:search]&.permit!,
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

    further_information =
      further_information_requests.map { :review_requested_information }

    {
      submitted_details:,
      recommendation: %i[initial_assessment],
      further_information:,
    }.compact_blank
  end

  def assessment_task_path(section, item, index)
    case section
    when :submitted_details
      url_helpers.assessor_interface_application_form_assessment_assessment_section_path(
        application_form,
        assessment,
        item,
      )
    when :recommendation
      status = assessment_task_status(section, item, index)

      return nil unless status == :not_started

      url_helpers.edit_assessor_interface_application_form_assessment_path(
        application_form,
        assessment,
      )
    when :further_information
      further_information_request = further_information_requests[index]
      return nil unless further_information_request.draft?

      url_helpers.assessor_interface_application_form_assessment_further_information_request_path(
        application_form,
        assessment,
        further_information_request,
      )
    end
  end

  def assessment_task_status(section, item, index)
    case section
    when :submitted_details
      assessment.sections.find { |s| s.key == item.to_s }.state
    when :recommendation
      return :cannot_start_yet unless assessment.sections_finished?
      return :completed if assessment.finished?
      return :not_started if further_information_requests.empty?
      :further_information_requested
    when :further_information
      further_information_requests[index].state.to_sym
    end
  end

  private

  attr_reader :params

  def assessment
    @assessment ||= application_form.assessment
  end

  def further_information_requests
    @further_information_requests ||=
      assessment.further_information_requests.order(:created_at).to_a
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
