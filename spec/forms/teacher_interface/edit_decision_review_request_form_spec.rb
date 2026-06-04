# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::EditDecisionReviewRequestForm, type: :model do
  subject(:form) do
    described_class.new(
      decision_review_request:,
      comment:,
      has_supporting_documents:,
    )
  end

  let(:decision_review_request) { create(:decision_review_request) }

  describe "validations" do
    let(:comment) { "" }
    let(:has_supporting_documents) { "" }

    it { is_expected.to validate_presence_of(:decision_review_request) }

    it do
      expect(subject).to validate_presence_of(:comment).with_message(
        "Enter the reason you are requesting a decision review",
      )
    end

    it do
      expect(subject).to validate_presence_of(
        :has_supporting_documents,
      ).with_message(
        "Select if you need to upload documents to support your decision review request",
      )
    end
  end

  describe "#save" do
    let(:comment) { "Decline was a mistake." }
    let(:has_supporting_documents) { "false" }

    it "updates the existing DecisionReviewRequest" do
      expect { form.save(validate: true) }.to change(
        decision_review_request,
        :comment,
      ).to(comment).and change(
              decision_review_request,
              :has_supporting_documents,
            ).to(false)
    end
  end
end
