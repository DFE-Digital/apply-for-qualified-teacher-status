# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class TeachingQualificationPartOfDegree < SitePrism::Page
      set_url "/teacher/application/qualifications/part-of-degree"

      element :heading, "h1"

      section :form, "form" do
        element :true_radio_item,
                "#teacher-interface-teaching-qualification-part-of-degree-form-" \
                  "teaching-qualification-part-of-degree-true-field",
                visible: false
        element :false_radio_item,
                "#teacher-interface-teaching-qualification-part-of-degree-form-" \
                  "teaching-qualification-part-of-degree-false-field",
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
