module PageObjects
  module AssessorInterface
    class ReviewFurtherInformationRequest < SitePrism::Page
      set_url "/assessor/applications/{application_form_id}/assessments/{assessment_id}" \
                "/further-information-requests/{further_information_request_id}/edit"

      element :heading, ".govuk-heading-xl"
      sections :summary_lists, GovukSummaryList, ".govuk-summary-list"

      section :form, "form" do
        section :yes_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(1)"
        section :no_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(2)"
        element :failure_reason_textarea, ".govuk-textarea"
        element :continue_button, "button"
      end
    end
  end
end
