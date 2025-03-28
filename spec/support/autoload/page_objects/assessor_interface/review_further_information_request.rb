# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ReviewFurtherInformationRequest < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/further-information-requests/{id}/edit"

      element :heading, ".govuk-heading-xl"

      sections :summary_cards, GovukSummaryList, ".govuk-summary-card"
      section :form, "form" do
        element :note_textarea, ".govuk-textarea"
        element :submit_button, ".govuk-button"
      end

      def submit_yes(items:)
        items.each do |item|
          form.find(
            "#assessor-interface-further-information-request-review-form-#{item.id}-decision-accept-field",
            visible: false,
          ).choose
        end

        form.submit_button.click
      end

      def submit_no(items:)
        items.each do |item|
          form.find(
            "#assessor-interface-further-information-request-review-form-#{item.id}-decision-decline-field",
            visible: false,
          ).choose
        end

        form.submit_button.click
      end
    end
  end
end
