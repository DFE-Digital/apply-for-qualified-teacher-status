# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class UploadDocument < SitePrism::Page
      set_url "/teacher/application/documents/{document_id}/uploads/new"

      element :heading, "h1"

      section :form, "form" do
        element :original_attachment,
                "#teacher-interface-upload-form-original-attachment-field"
        element :translated_attachment,
                "#teacher-interface-upload-form-translated-attachment-field"

        sections :written_in_english_items,
                 GovukRadioItem,
                 ".govuk-radios__item"

        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
        element :save_and_come_back_later_button,
                ".govuk-button.govuk-button--secondary"
      end
    end
  end
end
