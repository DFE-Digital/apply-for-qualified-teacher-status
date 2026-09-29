# frozen_string_literal: true

require "rails_helper"

RSpec.describe FeedbackSubmissionsExportContent do
  describe ".csv_headers" do
    subject(:csv_headers) { described_class.csv_headers }

    it "returns the headers for the CSV" do
      expect(subject).to eq(
        [
          "ID",
          "Status",
          "Rating",
          "Comments",
          "Submitted date",
          "Submitted time",
        ],
      )
    end
  end

  describe ".csv_row" do
    subject(:csv_row) { described_class.csv_row(feedback_submission) }

    let(:feedback_submission) do
      FeedbackSubmission.new(
        id: 123,
        application_status: "not_started",
        overall_experience: "highly_satisfied",
        comment: "Great service",
        submitted_at: Time.zone.local(2023, 1, 1, 12, 0, 0),
      )
    end

    it "returns the row data" do
      expect(subject).to eq(
        [
          "0123",
          "Not started",
          "Highly satisfied",
          "Great service",
          "2023-01-01",
          "12:00:00",
        ],
      )
    end
  end
end
