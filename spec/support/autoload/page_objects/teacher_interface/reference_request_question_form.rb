# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class ReferenceRequestQuestionForm < SitePrism::Page
      section :form, "form" do
        sections :radio_items,
                 PageObjects::GovukRadioItem,
                 ".govuk-radios__item"
        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      end

      def submit_yes
        form.radio_items.first.choose
        form.continue_button.click
      end

      def submit_no
        form.radio_items.second.choose
        form.continue_button.click
      end
    end
  end
end
