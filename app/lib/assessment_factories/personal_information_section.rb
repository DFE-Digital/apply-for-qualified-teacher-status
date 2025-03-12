# frozen_string_literal: true

module AssessmentFactories
  class PersonalInformationSection
    def initialize(application_form:)
      @application_form = application_form
    end

    def checks
      [
        (
          if application_form.requires_passport_as_identity_proof?
            %i[expiry_date_valid passport_document_valid]
          else
            :identification_document_present
          end
        ),
        (
          :name_change_document_present if application_form.has_alternative_name
        ),
        :duplicate_application,
        :applicant_already_qts,
        :applicant_already_dqt,
      ].flatten.compact
    end

    def failure_reasons
      reasons = [
        (
          if application_form.requires_passport_as_identity_proof?
            [
              FailureReasons::PASSPORT_DOCUMENT_EXPIRED,
              FailureReasons::PASSPORT_DOCUMENT_ILLEGIBLE,
              FailureReasons::PASSPORT_DOCUMENT_MISMATCH,
            ]
          else
            [
              FailureReasons::IDENTIFICATION_DOCUMENT_EXPIRED,
              FailureReasons::IDENTIFICATION_DOCUMENT_ILLEGIBLE,
              FailureReasons::IDENTIFICATION_DOCUMENT_MISMATCH,
            ]
          end
        ),
        (
          if application_form.has_alternative_name
            FailureReasons::NAME_CHANGE_DOCUMENT_ILLEGIBLE
          end
        ),
        (
          if application_form.english_language_citizenship_exempt
            if application_form.requires_passport_as_identity_proof?
              FailureReasons::EL_EXEMPTION_BY_CITIZENSHIP_PASSPORT_UNCONFIRMED
            else
              FailureReasons::EL_EXEMPTION_BY_CITIZENSHIP_ID_UNCONFIRMED
            end
          end
        ),
        FailureReasons::DUPLICATE_APPLICATION,
        FailureReasons::APPLICANT_ALREADY_QTS,
        FailureReasons::APPLICANT_ALREADY_DQT,
      ].flatten.compact

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
