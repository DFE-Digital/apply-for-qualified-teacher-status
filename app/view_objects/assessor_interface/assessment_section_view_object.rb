# frozen_string_literal: true

module AssessorInterface
  class AssessmentSectionViewObject
    def initialize(params:)
      @params = params
    end

    def assessment_section
      @assessment_section ||=
        AssessmentSection.includes(
          assessment: {
            application_form: {
              region: :country,
            },
          },
        ).find_by!(
          id: params[:id],
          assessment_id: params[:assessment_id],
          application_form: {
            reference: params[:application_form_reference],
          },
        )
    end

    delegate :assessment, to: :assessment_section
    delegate :application_form, :professional_standing_request, to: :assessment
    delegate :registration_number,
             :requires_preliminary_check,
             to: :application_form
    delegate :checks,
             :failure_reasons,
             :preliminary?,
             :selected_failure_reasons,
             to: :assessment_section
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

    def selected_work_histories_for(failure_reason:)
      selected_failure_reasons.find_by(key: failure_reason)&.work_histories
    end

    def qualifications_can_be_updated?
      application_form.not_started_stage? ||
        application_form.assessment_stage? || application_form.review_stage?
    end

    def show_form?
      return true if preliminary?

      if requires_preliminary_check &&
           !assessment.all_preliminary_sections_passed?
        return false
      end

      return false if show_english_language_exemption_content?

      if assessment_section.professional_standing? &&
           !professional_standing_request_received?
        return false
      end

      true
    end

    def disable_form?
      return true unless show_form?
      return true unless assessment.unknown?

      preliminary? ? assessment.all_preliminary_sections_passed? : false
    end

    def show_english_language_exemption_content?
      assessment_section.english_language_proficiency? &&
        application_form.english_language_exempt?
    end

    def show_english_language_provider_details?
      assessment_section.english_language_proficiency? &&
        (
          application_form.english_language_proof_method_provider? ||
            application_form.english_language_proof_method_esol?
        )
    end

    def show_english_language_exemption_checkbox?
      return false if preliminary?

      (
        application_form.english_language_citizenship_exempt == true &&
          assessment_section.personal_information?
      ) ||
        (
          application_form.english_language_qualification_exempt == true &&
            assessment_section.qualifications?
        )
    end

    def show_teacher_name_and_date_of_birth?
      !assessment_section.personal_information?
    end

    def teacher_name_and_date_of_birth
      [
        application_form.given_names,
        application_form.family_name,
        "(#{application_form.date_of_birth.to_fs})",
      ].join(" ")
    end

    def work_history_application_forms_contact_email_used_as_teacher
      @work_history_application_forms_contact_email_used_as_teacher ||=
        begin
          return {} if work_history_canonical_contact_emails.empty?

          ApplicationForm
            .includes(:teacher)
            .where.not(submitted_at: nil)
            .where(
              teacher: {
                canonical_email: work_history_canonical_contact_emails,
              },
            )
            .where.not(id: application_form.id)
            .group_by do |application_form|
              application_form.teacher.canonical_email
            end
        end
    end

    def work_history_application_forms_contact_email_used_as_reference
      @work_history_application_forms_contact_email_used_as_reference ||=
        begin
          return {} if work_history_canonical_contact_emails.empty?

          WorkHistory
            .includes(:application_form)
            .where(
              canonical_contact_email: work_history_canonical_contact_emails,
            )
            .where.not(application_form:)
            .where.not(application_form: { submitted_at: nil })
            .group_by(&:canonical_contact_email)
            .transform_values do |work_histories|
              work_histories.map(&:application_form)
            end
        end
    end

    def highlighted_work_history_contact_emails
      application_form.work_histories.select do |work_history|
        work_history_application_forms_contact_email_used_as_teacher[
          work_history.canonical_contact_email
        ].present? ||
          work_history_application_forms_contact_email_used_as_reference[
            work_history.canonical_contact_email
          ].present?
      end
    end

    delegate :work_histories, to: :application_form

    private

    attr_reader :params

    def build_key(failure_reason, key_section)
      key =
        if FailureReasons.passport_expired?(failure_reason)
          "passport_expired"
        elsif FailureReasons.fraud?(failure_reason)
          "fraud"
        elsif FailureReasons.suitability?(failure_reason)
          "suitability"
        elsif FailureReasons.decline?(failure_reason)
          "decline"
        elsif FailureReasons.further_information_request_document_type(
              failure_reason,
            ).present?
          "document"
        else
          "text"
        end

      "helpers.#{key_section}.assessor_interface_assessment_section_form.failure_reason_notes.#{key}"
    end

    def professional_standing_request_received?
      professional_standing_request.nil? ||
        professional_standing_request.received?
    end

    def work_history_canonical_contact_emails
      if assessment_section.work_history?
        application_form
          .work_histories
          .map(&:canonical_contact_email)
          .compact_blank
      else
        []
      end
    end
  end
end
