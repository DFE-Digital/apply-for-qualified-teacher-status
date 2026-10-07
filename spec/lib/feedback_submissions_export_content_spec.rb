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

    ["=", "+", "-", "@", "\t", "\r"].each do |prefix|
      context "when the comment starts with #{prefix.inspect}" do
        before { feedback_submission.comment = "#{prefix}HYPERLINK(\"x\")" }

        it "prefixes the comment with an apostrophe" do
          expect(csv_row[3]).to eq("'#{prefix}HYPERLINK(\"x\")")
        end
      end
    end

    context "when the comment contains a formula character later on" do
      before { feedback_submission.comment = "Score = 10" }

      it "leaves the comment unchanged" do
        expect(csv_row[3]).to eq("Score = 10")
      end
    end

    context "when the comment is nil" do
      before { feedback_submission.comment = nil }

      it "returns nil for the comment" do
        expect(csv_row[3]).to be_nil
      end
    end
  end
end
