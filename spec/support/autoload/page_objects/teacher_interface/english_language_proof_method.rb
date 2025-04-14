# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class EnglishLanguageProofMethod < SitePrism::Page
      set_url "/teacher/application/english-language/proof-method"

      element :heading, "h1"

      section :form, "form" do
        section :medium_of_instruction_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(1)"
        section :provider_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(2)"
        section :esol_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(3)"

        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
        element :save_and_come_back_later_button,
                ".govuk-button.govuk-button--secondary"
      end
    end
  end
end
