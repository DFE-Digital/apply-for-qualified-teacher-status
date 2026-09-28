# frozen_string_literal: true

class FeedbackSubmissionsExportContent
  class << self
    def csv_headers
      ["ID", "Status", "Rating", "Comments", "Submitted date", "Submitted time"]
    end

    def csv_row(feedback_submission)
      [
        feedback_submission.id.to_s.rjust(4, "0"),
        feedback_submission.application_status&.humanize,
        feedback_submission.overall_experience&.humanize,
        feedback_submission.comment,
        feedback_submission.submitted_at&.strftime("%Y-%m-%d"),
        feedback_submission.submitted_at&.strftime("%H:%M:%S"),
      ]
    end
  end
end
