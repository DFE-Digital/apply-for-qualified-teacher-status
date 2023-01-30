# frozen_string_literal: true

class AssessorInterface::QualificationsForm < AssessorInterface::AssessmentSectionForm
  include AssessorInterface::UpdatesEnglishLanguageStatus

  EXEMPTION_ATTR = :english_language_qualification_exempt
end
