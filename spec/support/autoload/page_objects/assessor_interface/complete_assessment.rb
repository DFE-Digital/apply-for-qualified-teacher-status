module PageObjects
  module AssessorInterface
    class CompleteAssessment < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}/edit"

      element :heading, "h1"
      sections :new_states, GovukRadioItem, ".govuk-radios__item"
      element :continue_button, ".govuk-button"

      def award_qts
        new_states.find { |radio_item| radio_item.label.text == "Award QTS" }
      end

      def award_qts_pending_verifications
        new_states.find do |radio_item|
          radio_item.label.text == "Award QTS pending verifications"
        end
      end

      def request_further_information
        new_states.find do |radio_item|
          radio_item.label.text == "Request further information"
        end
      end

      def decline_qts
        new_states.find { |radio_item| radio_item.label.text == "Decline QTS" }
      end

      def send_for_review
        new_states.find do |radio_item|
          radio_item.label.text == "Send application for review"
        end
      end
    end
  end
end
