# frozen_string_literal: true

class AssessorInterface::ApplicationFormsShowViewObject
  def initialize(params:)
    @params = params
  end

  def application_form
    @application_form ||=
      ApplicationForm.includes(assessment: :sections).find(params[:id])
  end

  def assessment_tasks
    pre_assessment_tasks = [
      (
        :professional_standing_request if professional_standing_request.present?
      ),
    ].compact

    assessment_section_keys = assessment.sections.map(&:key).map(&:to_sym)

    initial_assessment =
      %i[
        personal_information
        qualifications
        age_range_subjects
        english_language_proficiency
        work_history
        professional_standing
      ].select { |key| assessment_section_keys.include?(key) } +
        %i[initial_assessment_recommendation]

    further_information =
      further_information_requests.map { :review_requested_information }

    verification_requests = [
      (:qualification_requests if qualification_requests.present?),
      (:reference_requests if reference_requests.present?),
    ].compact

    if verification_requests.present?
      verification_requests << :assessment_recommendation
    end

    {
      pre_assessment_tasks:,
      initial_assessment:,
      further_information_requests: further_information,
      verification_requests:,
    }.compact_blank
  end

  def assessment_task_path(section, item, index)
    case section
    when :pre_assessment_tasks
      url_helpers.edit_assessor_interface_application_form_assessment_professional_standing_request_path(
        application_form,
        assessment,
      )
    when :initial_assessment
      if item == :initial_assessment_recommendation
        return nil if initial_assessment_recommendation_complete?
        return nil unless assessment.recommendable?

        url_helpers.edit_assessor_interface_application_form_assessment_path(
          application_form,
          assessment,
        )
      else
        url_helpers.assessor_interface_application_form_assessment_assessment_section_path(
          application_form,
          assessment,
          item,
        )
      end
    when :further_information_requests
      further_information_request = further_information_requests[index]

      if further_information_request.received?
        url_helpers.edit_assessor_interface_application_form_assessment_further_information_request_path(
          application_form,
          assessment,
          further_information_request,
        )
      end
    when :verification_requests
      return nil unless professional_standing_request_received?

      case item
      when :assessment_recommendation
        return nil unless assessment.recommendable?

        url_helpers.edit_assessor_interface_application_form_assessment_path(
          application_form,
          assessment,
        )
      when :qualification_requests
        qualification_request = qualification_requests[index]

        url_helpers.edit_assessor_interface_application_form_assessment_qualification_request_path(
          application_form,
          assessment,
          qualification_request,
        )
      when :reference_requests
        url_helpers.assessor_interface_application_form_assessment_verify_references_path(
          application_form,
          assessment,
        )
      end
    end
  end

  def assessment_task_status(section, item, index)
    case section
    when :pre_assessment_tasks
      professional_standing_request_received? ? :completed : :waiting_on
    when :initial_assessment
      if item == :initial_assessment_recommendation
        return :completed if initial_assessment_recommendation_complete?
        return :cannot_start unless assessment.recommendable?
        return :in_progress if request_further_information_unfinished?
        :not_started
      else
        return :cannot_start unless professional_standing_request_received?
        assessment.sections.find { |s| s.key == item.to_s }.status
      end
    when :further_information_requests
      return :cannot_start unless professional_standing_request_received?
      further_information_request = further_information_requests[index]
      return :cannot_start if further_information_request.requested?
      return :not_started if further_information_request.passed.nil?
      return :in_progress if assessment.request_further_information?
      :completed
    when :verification_requests
      case item
      when :reference_requests
        return :completed if assessment.references_verified
        application_form.received_reference ? :received : :waiting_on
      when :qualification_requests
        application_form.received_qualification ? :received : :waiting_on
      when :assessment_recommendation
        return :completed if assessment.completed?
        return :cannot_start unless assessment.recommendable?
        :not_started
      end
    end
  end

  def status
    application_form.status.humanize
  end

  private

  attr_reader :params

  delegate :assessment, to: :application_form
  delegate :professional_standing_request, to: :assessment

  def professional_standing_request_received?
    professional_standing_request.nil? ||
      professional_standing_request.received?
  end

  def request_further_information_unfinished?
    assessment.request_further_information? &&
      further_information_requests.empty?
  end

  def initial_assessment_recommendation_complete?
    !assessment.unknown? && !request_further_information_unfinished?
  end

  def further_information_requests
    @further_information_requests ||=
      assessment.further_information_requests.order(:created_at).to_a
  end

  def qualification_requests
    @qualification_requests ||=
      assessment.qualification_requests.order(:created_at).to_a
  end

  def reference_requests
    @reference_requests ||=
      assessment.reference_requests.order(:created_at).to_a
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
