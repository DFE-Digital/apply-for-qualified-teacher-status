# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class EditWrittenStatement < SitePrism::Page
      set_url "/teacher/application/written_statement/edit"

      section :form, "form" do
        section :written_statement_confirmation_checkbox,
                GovukCheckboxItem,
                ".govuk-checkboxes__item"

        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
        element :save_and_come_back_later_button,
                ".govuk-button.govuk-button--secondary"
      end
    end
  end
end
