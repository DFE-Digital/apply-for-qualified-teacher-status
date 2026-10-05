# frozen_string_literal: true

class FeedbackSubmissionsExportContent
  # Characters that spreadsheet applications treat as the start of a formula.
  FORMULA_PREFIXES = ["=", "+", "-", "@", "\t", "\r"].freeze

  class << self
    def csv_headers
      ["ID", "Status", "Rating", "Comments", "Submitted date", "Submitted time"]
    end

    def csv_row(feedback_submission)
      [
        feedback_submission.id.to_s.rjust(4, "0"),
        feedback_submission.application_status&.humanize,
        feedback_submission.overall_experience&.humanize,
        escape_formula(feedback_submission.comment),
        feedback_submission.submitted_at&.strftime("%Y-%m-%d"),
        feedback_submission.submitted_at&.strftime("%H:%M:%S"),
      ]
    end

    private

    def escape_formula(value)
      return value unless value&.start_with?(*FORMULA_PREFIXES)

      "'#{value}"
    end
  end
end
