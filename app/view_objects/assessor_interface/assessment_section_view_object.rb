# frozen_string_literal: true

module AssessorInterface
  class AssessmentSectionViewObject
    def initialize(params:)
      @params = params
    end

    def assessment_section
      @assessment_section ||=
        AssessmentSection
          .includes(assessment: { application_form: { region: :country } })
          .where(
            assessment_id: params[:assessment_id],
            assessment: {
              application_form_id: params[:application_form_id],
            },
          )
          .find_by!(key: params[:key])
    end

    delegate :assessment, to: :assessment_section
    delegate :application_form, :professional_standing_request, to: :assessment
    delegate :registration_number, to: :application_form
    delegate :checks, to: :assessment_section
    delegate :region, :country, to: :application_form

    def notes_label_key_for(failure_reason:)
      build_key(failure_reason, "label")
    end

    def notes_hint_key_for(failure_reason:)
      build_key(failure_reason, "hint")
    end

    def notes_placeholder_key_for(failure_reason:)
      build_key(failure_reason, "placeholder")
    end

    def render_form?
      professional_standing_request_received? && !render_section_content?
    end

    def render_section_content?
      assessment_section.english_language_proficiency? &&
        application_form.english_language_exempt?
    end

    def show_english_language_provider_details?
      assessment_section.english_language_proficiency? &&
        application_form.english_language_proof_method_provider?
    end

    def show_english_language_moi_details?
      assessment_section.english_language_proficiency? &&
        application_form.english_language_proof_method_medium_of_instruction?
    end

    def show_english_language_exemption_checkbox?
      (
        application_form.english_language_citizenship_exempt == true &&
          assessment_section.personal_information?
      ) ||
        (
          application_form.english_language_qualification_exempt == true &&
            assessment_section.qualifications?
        )
    end

    private

    attr_reader :params

    delegate :professional_standing_request, to: :assessment

    def build_key(failure_reason, key_section)
      key =
        "helpers.#{key_section}.assessor_interface_assessment_section_form.failure_reason_notes"
      FailureReasons.decline?(failure_reason:) ? "#{key}_decline" : key
    end

    def professional_standing_request_received?
      professional_standing_request.nil? ||
        professional_standing_request.received?
    end
  end
end
