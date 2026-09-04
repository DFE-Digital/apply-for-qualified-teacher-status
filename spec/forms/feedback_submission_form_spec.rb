# frozen_string_literal: true

require "rails_helper"

RSpec.describe FeedbackSubmissionForm, type: :model do
  subject(:form) do
    described_class.new(overall_experience:, application_status:, comment:)
  end

  describe "validations" do
    let(:overall_experience) { "" }
    let(:application_status) { "" }
    let(:comment) { "" }

    it { is_expected.to validate_presence_of(:overall_experience) }
    it { is_expected.to validate_presence_of(:application_status) }

    it { is_expected.not_to validate_presence_of(:comment) }

    context "when comment is less than 2000 characters long" do
      let(:overall_experience) { "highly_satisfied" }
      let(:application_status) { "application_submitted" }
      let(:comment) { "I need some help!" }

      it { is_expected.to be_valid }
    end

    context "when comment is over 2000 characters long" do
      let(:overall_experience) { "highly_satisfied" }
      let(:application_status) { "application_submitted" }
      let(:comment) { "I need some help!" * 2000 }

      it { is_expected.not_to be_valid }
    end

    context "when comment is blank" do
      let(:overall_experience) { "highly_satisfied" }
      let(:application_status) { "application_submitted" }
      let(:comment) { "" }

      it { is_expected.to be_valid }
    end
  end

  describe "#save" do
    let(:overall_experience) { "highly_satisfied" }
    let(:application_status) { "application_submitted" }
    let(:comment) { "I need some help!" * 3 }

    it "generates a new feedback submission record" do
      expect { form.save }.to change(FeedbackSubmission, :count).by(1)

      feedback_submission = FeedbackSubmission.last

      expect(feedback_submission).to have_attributes(
        overall_experience:,
        application_status:,
        comment:,
      )
      expect(feedback_submission.submitted_at).to be_present
    end
  end
end
