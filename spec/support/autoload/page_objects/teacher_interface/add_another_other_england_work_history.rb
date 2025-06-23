# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class AddAnotherOtherEnglandWorkHistory < SitePrism::Page
      set_url "/teacher/application/other_england_work_histories/add-another"

      element :heading, "h1"

      section :form, "form" do
        element :true_radio_item,
                "#teacher-interface-add-another-other-england-work-history-form-" \
                  "add-another-true-field",
                visible: false
        element :false_radio_item,
                "#teacher-interface-add-another-other-england-work-history-form-" \
                  "add-another-false-field",
                visible: false

        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
        element :save_and_come_back_later_button,
                ".govuk-button.govuk-button--secondary"
      end

      def submit_yes
        form.true_radio_item.click
        form.continue_button.click
      end

      def submit_no
        form.false_radio_item.click
        form.continue_button.click
      end
    end
  end
end
