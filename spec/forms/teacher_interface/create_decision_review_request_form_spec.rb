# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::CreateDecisionReviewRequestForm,
               type: :model do
  subject(:form) do
    described_class.new(application_form:, comment:, has_supporting_documents:)
  end

  let(:application_form) do
    create(
      :application_form,
      :with_assessment,
      :declined,
      declined_at: 1.day.ago,
    )
  end

  describe "validations" do
    let(:comment) { "" }
    let(:has_supporting_documents) { "" }

    it { is_expected.to validate_presence_of(:application_form) }

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
    let(:has_supporting_documents) { "true" }

    it "creates a new DecisionReviewRequest" do
      expect { form.save(validate: true) }.to change {
        application_form.assessment.decision_review_requests.count
      }.by(1)

      expect(
        application_form
          .assessment
          .decision_review_request_for_current_decline
          .comment,
      ).to eq(comment)
      expect(
        application_form
          .assessment
          .decision_review_request_for_current_decline
          .has_supporting_documents,
      ).to be true
    end
  end
end
