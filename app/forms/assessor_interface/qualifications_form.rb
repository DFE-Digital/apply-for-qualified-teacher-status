# frozen_string_literal: true

class AssessorInterface::QualificationsForm < AssessorInterface::AssessmentSectionForm
  include AssessorInterface::UpdatesEnglishLanguageStatus

  EXEMPTION_ATTR = :english_language_qualification_exempt

  validates :english_language_section_passed,
            presence: true,
            if: :requires_english_language_section_passed?

  private

  def requires_english_language_section_passed?
    !assessment_section.preliminary? && english_language_qualification_exempt?
  end

  def english_language_qualification_exempt?
    application_form.english_language_qualification_exempt?
  end
end
