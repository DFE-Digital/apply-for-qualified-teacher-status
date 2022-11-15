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
        age_range_subjects
        work_history
        professional_standing
      ].select { |key| assessment_section_keys.include?(key) }

    recommendation = %i[initial_assessment]

    further_information =
      further_information_requests.map { :review_requested_information }

    { submitted_details:, recommendation:, further_information: }.compact_blank
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
      return nil unless assessment.sections_finished?

      if item == :initial_assessment && assessment_editable?
        if assessment.can_award?
          url_helpers.edit_assessor_interface_application_form_assessment_age_range_subjects_path(
            application_form,
            assessment,
          )
        else
          url_helpers.edit_assessor_interface_application_form_assessment_path(
            application_form,
            assessment,
          )
        end
      end
    when :further_information
      further_information_request = further_information_requests[index]

      if further_information_request.received? &&
           (
             further_information_request.passed.nil? ||
               assessment.request_further_information?
           )
        url_helpers.edit_assessor_interface_application_form_assessment_further_information_request_path(
          application_form,
          assessment,
          further_information_request,
        )
      end
    end
  end

  def assessment_task_status(section, item, index)
    case section
    when :submitted_details
      assessment.sections.find { |s| s.key == item.to_s }.state
    when :recommendation
      return :cannot_start_yet unless assessment.sections_finished?
      return :not_started if assessment.unknown?
      return :in_progress if assessment_editable?
      :completed
    when :further_information
      further_information_request = further_information_requests[index]
      return :cannot_start_yet if further_information_request.requested?
      return :not_started if further_information_request.passed.nil?
      return :in_progress if assessment.request_further_information?
      :completed
    end
  end

  def status
    application_form.state.humanize
  end

  private

  attr_reader :params

  def assessment
    @assessment ||= application_form.assessment
  end

  def assessment_editable?
    assessment.unknown? ||
      (
        assessment.request_further_information? &&
          further_information_requests.empty?
      )
  end

  def further_information_requests
    @further_information_requests ||=
      assessment.further_information_requests.order(:created_at).to_a
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
