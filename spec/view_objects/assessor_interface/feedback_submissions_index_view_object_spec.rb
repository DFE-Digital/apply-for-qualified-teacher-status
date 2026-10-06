# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::FeedbackSubmissionsIndexViewObject do
  subject(:view_object) { described_class.new(params:, session:) }

  let(:params) { {} }
  let(:session) { {} }

  describe "#feedback_submissions_pagy" do
    subject(:feedback_submissions_pagy) do
      view_object.feedback_submissions_pagy
    end

    it { is_expected.not_to be_nil }

    it "is configured correctly" do
      expect(feedback_submissions_pagy.limit).to eq(20)
      expect(feedback_submissions_pagy.page).to eq(1)
    end
  end

  describe "#feedback_submissions_records" do
    subject(:feedback_submissions_records) do
      view_object.feedback_submissions_records
    end

    it { is_expected.to be_empty }

    context "with feedback submissions" do
      let!(:oldest) do
        FeedbackSubmission.create!(submitted_at: Time.zone.local(2023, 1, 1))
      end
      let!(:newest) do
        FeedbackSubmission.create!(submitted_at: Time.zone.local(2023, 1, 2))
      end

      it "returns feedback submissions ordered newest first" do
        expect(feedback_submissions_records).to eq([newest, oldest])
      end
    end

    context "with more than one page of feedback submissions" do
      before do
        21.times do |index|
          FeedbackSubmission.create!(
            submitted_at: Time.zone.local(2023, 1, 1) + index.hours,
          )
        end
      end

      it "limits the records to 20" do
        expect(feedback_submissions_records.length).to eq(20)
      end
    end
  end

  describe "#feedback_submissions_scope" do
    subject(:feedback_submissions_scope) do
      view_object.feedback_submissions_scope
    end

    let(:session) do
      {
        feedback_submissions_filter_params: {
          "submitted_at_after(1i)" => "2023",
          "submitted_at_after(2i)" => "1",
          "submitted_at_after(3i)" => "2",
        },
      }
    end

    let!(:new_submission) do
      FeedbackSubmission.create!(submitted_at: Time.zone.local(2023, 5, 1))
    end

    let!(:newest_submission) do
      FeedbackSubmission.create!(submitted_at: Time.zone.local(2023, 8, 1))
    end

    let!(:oldest_submission) do
      FeedbackSubmission.create!(submitted_at: Time.zone.local(2022, 6, 1))
    end

    it "filters out submissions before the start date and orders them newest first" do
      expect(feedback_submissions_scope).to eq(
        [newest_submission, new_submission],
      )
    end

    context "with a submitted before filter" do
      let(:session) do
        {
          feedback_submissions_filter_params: {
            "submitted_at_before(1i)" => "2023",
            "submitted_at_before(2i)" => "6",
            "submitted_at_before(3i)" => "1",
          },
        }
      end

      it "filters out submissions after the end date and orders them newest first" do
        expect(feedback_submissions_scope).to eq(
          [new_submission, oldest_submission],
        )
      end
    end

    context "with submitted after and before filters" do
      let(:session) do
        {
          feedback_submissions_filter_params: {
            "submitted_at_after(1i)" => "2023",
            "submitted_at_after(2i)" => "1",
            "submitted_at_after(3i)" => "1",
            "submitted_at_before(1i)" => "2023",
            "submitted_at_before(2i)" => "6",
            "submitted_at_before(3i)" => "1",
          },
        }
      end

      it "returns submissions within the date range" do
        expect(feedback_submissions_scope).to eq([new_submission])
      end
    end
  end

  describe "#filter_form" do
    subject(:filter_form) { view_object.filter_form }

    let(:session) do
      {
        feedback_submissions_filter_params: {
          submitted_at_after: "2023-01-01",
          submitted_at_before: "2023-01-31",
        },
      }
    end

    it "returns a filter form populated from the session" do
      expect(filter_form).to be_a(
        AssessorInterface::FeedbackSubmissionFilterForm,
      )
      expect(filter_form).to have_attributes(
        submitted_at_after: "2023-01-01",
        submitted_at_before: "2023-01-31",
      )
    end
  end
end
