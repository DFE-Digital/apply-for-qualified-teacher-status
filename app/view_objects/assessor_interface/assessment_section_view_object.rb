# frozen_string_literal: true

module AssessorInterface
  class AssessmentSectionViewObject
    def initialize(params:)
      @params = params
    end

    def assessment_section
      @assessment_section ||=
        AssessmentSection
          .includes(assessment: :application_form)
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

    private

    attr_reader :params
  end
end
