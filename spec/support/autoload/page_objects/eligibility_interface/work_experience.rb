# frozen_string_literal: true

module PageObjects
  module EligibilityInterface
    class WorkExperience < Question
      set_url "/eligibility/work-experience"

      def submit_under_9_months
        form.radio_items[0].choose
        form.continue_button.click
      end

      def submit_between_9_and_20_months
        form.radio_items[1].choose
        form.continue_button.click
      end

      def submit_over_20_months
        form.radio_items[2].choose
        form.continue_button.click
      end
    end
  end
end
