# frozen_string_literal: true

module AssessmentFactories
  class EnglishLanguageProficiencySection
    def initialize(application_form:)
      @application_form = application_form
    end

    def checks
      if application_form.english_language_exempt?
        []
      elsif application_form.english_language_proof_method_medium_of_instruction?
        %i[english_language_valid_moi]
      elsif application_form.english_language_proof_method_esol?
        %i[english_language_esol_provider english_language_valid_esol]
      else
        %i[english_language_valid_provider]
      end
    end

    def failure_reasons
      reasons =
        if application_form.english_language_exempt?
          []
        elsif application_form.english_language_proof_method_medium_of_instruction?
          [
            FailureReasons::EL_MOI_NOT_TAUGHT_IN_ENGLISH,
            FailureReasons::EL_MOI_INVALID_FORMAT,
          ]
        elsif application_form.english_language_proof_method_esol?
          [
            FailureReasons::EL_REQUIRE_ALTERNATIVE,
            FailureReasons::EL_ESOL_DOCUMENT_ILLEGIBLE,
            FailureReasons::EL_ESOL_EXPIRED,
            FailureReasons::EL_QUALIFICATION_INVALID,
            FailureReasons::EL_ESOL_BELOW_REQUIRED_LEVEL,
          ]
        else
          [
            FailureReasons::EL_QUALIFICATION_INVALID,
            (
              if application_form.english_language_provider_other
                FailureReasons::EL_PROFICIENCY_DOCUMENT_ILLEGIBLE
              else
                FailureReasons::EL_UNVERIFIABLE_REFERENCE_NUMBER
              end
            ),
            FailureReasons::EL_GRADE_BELOW_B2,
            FailureReasons::EL_SELT_EXPIRED,
            FailureReasons::EL_REQUIRE_ALTERNATIVE,
          ]
        end

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
  end
end
