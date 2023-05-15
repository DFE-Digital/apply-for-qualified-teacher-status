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

    def teacher_name_and_date_of_birth
      [
        application_form.given_names,
        application_form.family_name,
        "(#{application_form.date_of_birth.to_fs(:long_ordinal_uk)})",
      ].join(" ")
    end

    def work_history_application_forms_contact_email_used_as_teacher
      @work_history_application_forms_contact_email_used_as_teacher ||=
        begin
          application_forms =
            ApplicationForm
              .includes(:teacher)
              .not_draft
              .where(
                teacher: {
                  canonical_email: work_history_canonical_contact_emails,
                },
              )
              .where.not(id: application_form.id)
              .to_a

          application_form.work_histories.index_with do |work_history|
            application_forms.select do |application_form|
              application_form.teacher.canonical_email ==
                work_history.canonical_contact_email
            end
          end
        end
    end

    def work_history_application_forms_contact_email_used_as_reference
      @work_history_application_forms_contact_email_used_as_reference ||=
        begin
          work_histories =
            WorkHistory
              .includes(:application_form)
              .where(
                canonical_contact_email: work_history_canonical_contact_emails,
              )
              .where.not(application_form:)
              .where.not(application_form: { status: "draft" })

          application_form.work_histories.index_with do |work_history|
            found_work_histories =
              work_histories.select do |found_work_history|
                found_work_history.canonical_contact_email ==
                  work_history.canonical_contact_email
              end

            found_work_histories.map(&:application_form)
          end
        end
    end

    def show_work_history_information_appears_in_other_applications?
      work_history_application_forms_contact_email_used_as_teacher.values.any?(
        &:present?
      ) ||
        work_history_application_forms_contact_email_used_as_reference.values.any?(
          &:present?
        )
    end

    def highlighted_work_history_contact_emails
      application_form.work_histories.select do |work_history|
        work_history_application_forms_contact_email_used_as_teacher[
          work_history
        ].present? ||
          work_history_application_forms_contact_email_used_as_reference[
            work_history
          ].present?
      end
    end

    private

    attr_reader :params

    delegate :professional_standing_request, to: :assessment

    def build_key(failure_reason, key_section)
      key =
        if FailureReasons.decline?(failure_reason:)
          "decline"
        elsif FailureReasons.further_information_request_document_type(
              failure_reason:,
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
        application_form.work_histories.map(&:canonical_contact_email)
      else
        []
      end
    end
  end
end
