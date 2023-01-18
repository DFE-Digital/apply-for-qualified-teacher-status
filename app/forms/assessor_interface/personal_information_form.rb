# frozen_string_literal: true

class AssessorInterface::PersonalInformationForm < AssessorInterface::AssessmentSectionForm
  include AssessorInterface::UpdatesEnglishLanguageStatus

  EXEMPTION_ATTR = :english_language_citizenship_exempt
end
