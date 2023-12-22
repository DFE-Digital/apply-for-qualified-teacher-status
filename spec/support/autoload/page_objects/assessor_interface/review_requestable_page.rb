# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ReviewRequestablePage < SitePrism::Page
      section :form, "form" do
        section :true_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(1)"
        section :false_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(2)"
        element :note_textarea, ".govuk-textarea"
        element :submit_button, ".govuk-button"
      end

      def submit_yes
        form.true_radio_item.choose
        form.submit_button.click
      end

      def submit_no(note:)
        form.false_radio_item.choose
        form.note_textarea.fill_in with: note
        form.submit_button.click
      end
    end
  end
end
