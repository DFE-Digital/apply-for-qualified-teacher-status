# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class MeetsCriteriaOtherEnglandWorkHistory < SitePrism::Page
      set_url "/teacher/application/other_england_work_histories/meets-criteria"

      element :heading, "h1"

      section :form, "form" do
        element :true_radio_item,
                "#teacher-interface-other-england-work-history-meets-criteria-form-" \
                  "has-other-england-work-history-true-field",
                visible: false
        element :false_radio_item,
                "#teacher-interface-other-england-work-history-meets-criteria-form-" \
                  "has-other-england-work-history-false-field",
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
