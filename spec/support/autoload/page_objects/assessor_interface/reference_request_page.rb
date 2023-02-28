# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ReferenceRequestPage < SitePrism::Page
      # rubocop:disable Layout/LineLength
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}/work-references/{reference_request_id}/edit"
      # rubocop:enable Layout/LineLength

      section :table, ".govuk-table" do
        elements :headers, ".govuk-table__header"
        elements :cells, ".govuk-table__cell"
      end

      section :responses, ".govuk-summary-card" do
        element :heading, ".govuk-summary-card__title"
        elements :keys, ".govuk-summary-list__key"
        elements :values, ".govuk-summary-list__value"
      end

      section :form, "form" do
        element :yes_radio_item,
                "#assessor-interface-requestable-review-form-passed-true-field",
                visible: false
        element :continue_button, ".govuk-button"
      end
    end
  end
end
