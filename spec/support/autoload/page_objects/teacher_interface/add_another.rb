# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class AddAnother < SitePrism::Page
      element :heading, "h1"

      section :form, "form" do
        section :true_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(1)"
        section :false_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(2)"

        element :submit_button, ".govuk-button:not(.govuk-button--secondary)"
      end

      def submit_yes
        form.true_radio_item.choose
        form.submit_button.click
      end

      def submit_no
        form.false_radio_item.choose
        form.submit_button.click
      end
    end
  end
end
