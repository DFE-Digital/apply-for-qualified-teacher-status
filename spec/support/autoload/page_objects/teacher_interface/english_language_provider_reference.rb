# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class EnglishLanguageProviderReference < SitePrism::Page
      set_url "/teacher/application/english-language/provider-reference"

      element :heading, "h1"

      section :form, "form" do
        element :reference_input, ".govuk-input"
        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
        element :save_and_come_back_later_button,
                ".govuk-button.govuk-button--secondary"
      end
    end
  end
end
