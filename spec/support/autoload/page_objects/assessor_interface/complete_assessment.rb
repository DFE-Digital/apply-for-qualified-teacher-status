module PageObjects
  module AssessorInterface
    class CompleteAssessment < SitePrism::Page
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}/edit"

      element :heading, "h1"
      sections :new_states, GovukRadioItem, ".govuk-radios__item"

      def award_qts
        new_states.find { |radio_item| radio_item.label.text == "Award QTS" }
      end

      def request_further_information
        new_states.find do |radio_item|
          radio_item.label.text == "Request further information"
        end
      end

      def decline_qts
        new_states.find { |radio_item| radio_item.label.text == "Decline QTS" }
      end
    end
  end
end
