# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class ReferenceRequestQuestionForm < SitePrism::Page
      section :form, "form" do
        section :yes_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(1)"
        section :no_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(2)"

        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      end

      def submit_yes
        form.yes_radio_item.choose
        form.continue_button.click
      end

      def submit_no
        form.no_radio_item.choose
        form.continue_button.click
      end
    end
  end
end
