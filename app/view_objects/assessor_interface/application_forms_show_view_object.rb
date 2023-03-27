# frozen_string_literal: true

class AssessorInterface::ApplicationFormsShowViewObject
  def initialize(params:)
    @params = params
  end

  def application_form
    @application_form ||=
      ApplicationForm
        .includes(assessment: :sections)
        .not_draft
        .find(params[:id])
  end

  def assessment_tasks
    pre_assessment_tasks = [
      (:preliminary_check if application_form.requires_preliminary_check),
      (
        if teaching_authority_provides_written_statement &&
             professional_standing_request.present?
          :await_professional_standing_request
        end
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

    verify_professional_standing =
      !teaching_authority_provides_written_statement &&
        professional_standing_request.present?

    verification_requests = [
      (:qualification_requests if qualification_requests.present?),
      (:reference_requests if reference_requests.present?),
      (:locate_professional_standing_request if verify_professional_standing),
      (:review_professional_standing_request if verify_professional_standing),
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
      if item == :preliminary_check
        url_helpers.assessor_interface_application_form_assessment_preliminary_check_path(
          application_form,
          assessment,
        )
      elsif assessment.preliminary_check_complete != false
        url_helpers.location_assessor_interface_application_form_assessment_professional_standing_request_path(
          application_form,
          assessment,
        )
      end
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
      return nil unless preassessment_professional_standing_request_completed?

      case item
      when :assessment_recommendation
        return nil unless assessment.recommendable?

        url_helpers.edit_assessor_interface_application_form_assessment_path(
          application_form,
          assessment,
        )
      when :locate_professional_standing_request
        url_helpers.location_assessor_interface_application_form_assessment_professional_standing_request_path(
          application_form,
          assessment,
        )
      when :review_professional_standing_request
        if professional_standing_request.received? ||
             professional_standing_request.ready_for_review
          url_helpers.review_assessor_interface_application_form_assessment_professional_standing_request_path(
            application_form,
            assessment,
          )
        end
      when :qualification_requests
        url_helpers.assessor_interface_application_form_assessment_qualification_requests_path(
          application_form,
          assessment,
        )
      when :reference_requests
        url_helpers.assessor_interface_application_form_assessment_reference_requests_path(
          application_form,
          assessment,
        )
      end
    end
  end

  def assessment_task_status(section, item, index)
    case section
    when :pre_assessment_tasks
      if item == :await_professional_standing_request
        return :cannot_start if cannot_start_professional_standing_request?
        if preassessment_professional_standing_request_completed?
          :completed
        else
          :waiting_on
        end
      else
        assessment.preliminary_check_complete.nil? ? :not_started : :completed
      end
    when :initial_assessment
      if item == :initial_assessment_recommendation
        return :completed if initial_assessment_recommendation_complete?
        return :cannot_start unless assessment.recommendable?
        return :in_progress if request_further_information_unfinished?
        :not_started
      else
        unless preassessment_professional_standing_request_completed?
          return :cannot_start
        end
        assessment.sections.find { |s| s.key == item.to_s }.status
      end
    when :further_information_requests
      unless preassessment_professional_standing_request_completed?
        return :cannot_start
      end
      further_information_request = further_information_requests[index]
      return :cannot_start if further_information_request.requested?
      return :not_started if further_information_request.passed.nil?
      return :in_progress if assessment.request_further_information?
      :completed
    when :verification_requests
      case item
      when :assessment_recommendation
        return :completed if assessment.completed?
        return :cannot_start unless assessment.recommendable?
        :not_started
      when :locate_professional_standing_request
        if professional_standing_request.ready_for_review ||
             professional_standing_request.received?
          :completed
        elsif professional_standing_request.expired?
          :overdue
        else
          :waiting_on
        end
      when :review_professional_standing_request
        if professional_standing_request.reviewed?
          :completed
        elsif professional_standing_request.received? ||
              professional_standing_request.ready_for_review
          :received
        else
          :cannot_start
        end
      when :reference_requests
        return :completed if assessment.references_verified

        unreviewed_requests = reference_requests.reject(&:reviewed?)

        if unreviewed_requests.empty?
          :in_progress
        elsif unreviewed_requests.any?(&:expired?)
          :overdue
        elsif unreviewed_requests.any?(&:received?)
          :received
        else
          :waiting_on
        end
      when :qualification_requests
        unreviewed_requests = qualification_requests.reject(&:reviewed?)

        if unreviewed_requests.empty?
          :completed
        elsif unreviewed_requests.any?(&:expired?)
          :overdue
        elsif unreviewed_requests.any?(&:received?)
          :received
        else
          :waiting_on
        end
      end
    end
  end

  def status
    application_form.status.humanize
  end

  private

  attr_reader :params

  delegate :assessment,
           :teaching_authority_provides_written_statement,
           to: :application_form
  delegate :professional_standing_request, to: :assessment

  def preassessment_professional_standing_request_completed?
    if teaching_authority_provides_written_statement
      professional_standing_request.received?
    else
      true
    end
  end

  def request_further_information_unfinished?
    assessment.request_further_information? &&
      further_information_requests.empty?
  end

  def initial_assessment_recommendation_complete?
    !assessment.unknown? && !request_further_information_unfinished?
  end

  def cannot_start_professional_standing_request?
    application_form.requires_preliminary_check &&
      !assessment.preliminary_check_complete
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
