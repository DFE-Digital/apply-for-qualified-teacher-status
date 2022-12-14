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
    delegate :application_form, to: :assessment
    delegate :registration_number, to: :application_form
    delegate :checks, to: :assessment_section
    delegate :region, to: :application_form

    def qualifications
      application_form.qualifications.ordered
    end

    def work_histories
      application_form.work_histories.ordered
    end

    def show_registration_number_summary
      registration_number.present?
    end

    def show_written_statement_summary
      application_form.written_statement_document.uploaded?
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

    def professional_standing?
      assessment_section.key == "professional_standing"
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
