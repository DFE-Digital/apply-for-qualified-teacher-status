# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class FeedbackSubmissions < SitePrism::Page
      set_url "/assessor/feedback"

      section :header, PageHeader, "nav"

      section :submitted_at_filter,
              "form[action='/assessor/feedback/filters/apply']" do
        element :start_day,
                "#assessor_interface_feedback_submission_filter_form_submitted_at_after_3i, " \
                  "#assessor-interface-feedback-submission-filter-form-submitted-at-after-field-error"
        element :start_month,
                "#assessor_interface_feedback_submission_filter_form_submitted_at_after_2i"
        element :start_year,
                "#assessor_interface_feedback_submission_filter_form_submitted_at_after_1i"
        element :end_day,
                "#assessor_interface_feedback_submission_filter_form_submitted_at_before_3i, " \
                  "#assessor-interface-feedback-submission-filter-form-submitted-at-before-field-error"
        element :end_month,
                "#assessor_interface_feedback_submission_filter_form_submitted_at_before_2i"
        element :end_year,
                "#assessor_interface_feedback_submission_filter_form_submitted_at_before_1i"
      end

      sections :feedback_rows, "table.govuk-table tbody .govuk-table__row" do
        element :id_link, "td:nth-child(1) a"
        element :status, "td:nth-child(2)"
        element :rating, "td:nth-child(3)"
        element :comments, "td:nth-child(4)"
        element :submitted_on, "td:nth-child(5)"
      end

      element :apply_filters, "div.govuk-button-group button"
      element :clear_filters, "div.govuk-button-group a.govuk-link"
      element :download_feedback,
              "a.govuk-button",
              text: "Download feedback (CSV)"
      section :error_summary, GovukErrorSummary, ".govuk-error-summary"
    end
  end
end
