# frozen_string_literal: true

class TeacherInterface::DocumentViewObject
  def initialize(document:)
    @document = document
  end

  attr_reader :document

  def section_caption
    if document.qualification_document? ||
         document.qualification_certificate? ||
         document.qualification_transcript?
      I18n.t("application_form.tasks.sections.qualifications")
    elsif document.name_change? || document.passport? ||
          document.identification?
      I18n.t("application_form.tasks.sections.about_you")
    elsif document.medium_of_instruction? ||
          document.english_language_proficiency?
      I18n.t("application_form.tasks.sections.english_language")
    elsif document.written_statement?
      I18n.t("application_form.tasks.sections.proof_of_recognition")
    end
  end
end
