# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class EditReferenceRequest < SitePrism::Page
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}" \
                "/reference-requests/{id}/edit"

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
