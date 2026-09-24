# frozen_string_literal: true

class AssessorInterface::PersonalInformationForm < AssessorInterface::AssessmentSectionForm
  include AssessorInterface::UpdatesEnglishLanguageStatus

  EXEMPTION_ATTR = :english_language_citizenship_exempt

  validates :english_language_section_passed,
            presence: {
              message: :blank_passport,
            },
            if: :requires_passport_as_identity_proof?
  validates :english_language_section_passed,
            presence: {
              message: :blank_id_documents,
            },
            unless: :requires_passport_as_identity_proof?

  private

  def requires_passport_as_identity_proof?
    assessment_section
      .assessment
      .application_form
      .requires_passport_as_identity_proof?
  end
end
