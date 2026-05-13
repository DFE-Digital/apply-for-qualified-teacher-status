# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ReviewDecisionReview < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/decision-review-requests/{decision_review_request_id}/edit"

      section :form, "form" do
        element :true_radio_item,
                "#assessor-interface-decision-review-request-review-form-review-passed-true-field",
                visible: false
        element :false_radio_item,
                "#assessor-interface-decision-review-request-review-form-review-passed-field",
                visible: false
        element :note_review_passed_textarea,
                "#assessor-interface-decision-review-request-review-form-review-passed-note-field"
        element :note_review_failed_textarea,
                "#assessor-interface-decision-review-request-review-form-review-failed-note-field"
        element :submit_button, ".govuk-button"
      end

      def submit_yes(note:)
        form.true_radio_item.choose
        form.note_review_passed_textarea.fill_in with: note
        form.submit_button.click
      end

      def submit_no(note:)
        form.false_radio_item.choose
        form.note_review_failed_textarea.fill_in with: note
        form.submit_button.click
      end
    end
  end
end
