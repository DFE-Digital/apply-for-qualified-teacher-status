# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class EditReferenceRequest < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/reference-requests/{id}/edit"

      section :summary_list, GovukSummaryList, "#reference-details-summary-list"

      section :responses, ".govuk-summary-card" do
        element :heading, ".govuk-summary-card__title"
        elements :keys, ".govuk-summary-list__key"
        elements :values, ".govuk-summary-list__value"
      end

      section :form, "form" do
        element :true_radio_item,
                "#assessor-interface-requestable-review-form-passed-true-field",
                visible: false
        element :continue_button, ".govuk-button"
      end
    end
  end
end
