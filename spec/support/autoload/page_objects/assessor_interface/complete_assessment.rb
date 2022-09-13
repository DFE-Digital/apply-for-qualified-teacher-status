module PageObjects
  module AssessorInterface
    class CompleteAssessment < SitePrism::Page
      set_url "/assessor/applications/{application_id}/complete-assessment"

      element :heading, "h1"
      sections :new_states, GovukRadioItem, ".govuk-radios__item"

      def award_qts
        new_states.find { |radio_item| radio_item.label.text == "Award QTS" }
      end

      def decline_qts
        new_states.find { |radio_item| radio_item.label.text == "Decline QTS" }
      end
    end
  end
end
