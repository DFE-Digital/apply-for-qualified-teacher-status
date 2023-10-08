# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ReviewVerifications < SitePrism::Page
      set_url "/assessor/applications/{application_form_id}/assessments/{assessment_id}" \
                "/review-verifications"

      sections :rows, ".govuk-table__row" do
        element :link, ".govuk-link"
        element :tag, ".govuk-tag"
      end

      element :back_to_overview_button, ".govuk-button"
    end
  end
end
