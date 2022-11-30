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

  def notes_from_assessors
    return [] if assessment.nil? || further_information_request.present?

    assessment.sections.filter_map do |section|
      next nil if section.selected_failure_reasons.blank?

      failure_reasons =
        section.selected_failure_reasons.map do |key, assessor_feedback|
          is_decline =
            AssessmentSection.decline_failure_reason?(failure_reason: key)
          assessor_feedback = "" unless is_decline

          { key:, is_decline:, assessor_feedback: }
        end

      failure_reasons =
        failure_reasons.sort_by do |failure_reason|
          [failure_reason[:is_decline] ? 0 : 1, failure_reason[:key]]
        end

      { assessment_section_key: section.key, failure_reasons: }
    end
  end

  def declined_cannot_reapply?
    return false if assessment.nil?

    assessment.sections.any? do |section|
      section.selected_failure_reasons.any? do |key, _|
        %w[authorisation_to_teach applicant_already_qts].include?(key)
      end
    end
  end

  def show_further_information_request_expired_content?
    further_information_request.present? && further_information_request.expired?
  end
end
