# frozen_string_literal: true

module AssessmentFactories
  class ProfessionalStandingSection
    def initialize(application_form:)
      @application_form = application_form
    end

    def checks
      [
        (:registration_number if has_registration_number),
        (:written_statement_present if written_statement_required),
        (:written_statement_recent if written_statement_required),
        (:written_statement_induction if written_statement_induction),
        (:written_statement_completion_date if written_statement_induction),
        (:written_statement_registration_number if written_statement_induction),
        (:written_statement_school_name if written_statement_induction),
        (:written_statement_signature if written_statement_induction),
        :authorisation_to_teach,
        :teaching_qualification,
        :confirm_age_range_subjects,
        :qualified_to_teach,
        :full_professional_status,
      ].compact
    end

    def failure_reasons
      reasons = [
        (FailureReasons::REGISTRATION_NUMBER if has_registration_number),
        (
          if has_registration_number
            FailureReasons::REGISTRATION_NUMBER_ALTERNATIVE
          end
        ),
        (
          if application_form.needs_written_statement
            FailureReasons::WRITTEN_STATEMENT_ILLEGIBLE
          end
        ),
        (
          FailureReasons::WRITTEN_STATEMENT_RECENT if written_statement_required
        ),
        (
          if written_statement_induction
            FailureReasons::WRITTEN_STATEMENT_INFORMATION
          end
        ),
        FailureReasons::AUTHORISATION_TO_TEACH,
        FailureReasons::TEACHING_QUALIFICATION,
        FailureReasons::CONFIRM_AGE_RANGE_SUBJECTS,
        FailureReasons::QUALIFIED_TO_TEACH,
        FailureReasons::FULL_PROFESSIONAL_STATUS,
      ].compact

      if suitability_active?
        reasons += [
          FailureReasons::SUITABILITY,
          FailureReasons::SUITABILITY_PREVIOUSLY_DECLINED,
          FailureReasons::FRAUD,
        ]
      end

      reasons
    end

    private

    attr_reader :application_form

    def suitability_active?
      @suitability_active ||= FeatureFlags::FeatureFlag.active?(:suitability)
    end

    def has_registration_number
      @has_registration_number ||= application_form.needs_registration_number
    end

    def written_statement_required
      @written_statement_required ||=
        application_form.needs_written_statement &&
          !application_form.written_statement_optional
    end

    def written_statement_induction
      @written_statement_induction ||=
        application_form.needs_written_statement &&
          !application_form.needs_work_history
    end
  end
end
