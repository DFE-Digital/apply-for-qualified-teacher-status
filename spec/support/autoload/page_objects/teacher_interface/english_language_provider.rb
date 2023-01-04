# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class EnglishLanguageProvider < SitePrism::Page
      set_url "/teacher/application/english-language/provider"

      element :heading, "h1"

      section :form, "form" do
        sections :radio_items,
                 PageObjects::GovukRadioItem,
                 ".govuk-radios__item"
        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
        element :save_and_come_back_later_button,
                ".govuk-button.govuk-button--secondary"
      end
    end
  end
end
