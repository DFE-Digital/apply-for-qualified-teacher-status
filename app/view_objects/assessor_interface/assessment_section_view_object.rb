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

    def qualifications
      application_form.qualifications.ordered
    end

    def work_histories
      application_form.work_histories.ordered
    end

    def work_history_months_count
      @months_count = WorkHistoryDuration.new(application_form:).count_months
    end

    def show_registration_number_summary
      application_form.needs_registration_number?
    end

    def show_written_statement_summary
      application_form.needs_written_statement?
    end

    def notes_label_key_for(failure_reason:)
      build_key(failure_reason, "label")
    end

    def notes_hint_key_for(failure_reason:)
      build_key(failure_reason, "hint")
    end

    def notes_placeholder_key_for(failure_reason:)
      build_key(failure_reason, "placeholder")
    end

    def online_checker_url
      @online_checker_url ||=
        region.teaching_authority_online_checker_url.presence ||
          region.country.teaching_authority_online_checker_url
    end

    def work_history?
      assessment_section.key == "work_history"
    end

    def professional_standing?
      assessment_section.key == "professional_standing"
    end

    def render_form?
      !render_section_content?
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

    private

    attr_reader :params

    def build_key(failure_reason, key_section)
      key =
        "helpers.#{key_section}.assessor_interface_assessment_section_form.failure_reason_notes"
      FailureReasons.decline?(failure_reason:) ? "#{key}_decline" : key
    end
  end
end
