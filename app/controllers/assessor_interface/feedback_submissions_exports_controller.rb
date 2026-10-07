# frozen_string_literal: true

module AssessorInterface
  class FeedbackSubmissionsExportsController < BaseController
    include ActionController::Live
    include CSVStreamable

    before_action only: %i[index] do
      authorize %i[assessor_interface feedback_submission]
    end

    def index
      @view_object = FeedbackSubmissionsIndexViewObject.new(params:, session:)

      set_csv_headers(
        filename: "feedback-submissions-#{Time.current.iso8601}.csv",
      )
      stream_csv(
        data: @view_object.feedback_submissions_scope,
        csv_content_class: FeedbackSubmissionsExportContent,
      )
    end
  end
end
