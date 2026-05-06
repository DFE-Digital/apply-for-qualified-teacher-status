# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::CreateDecisionReviewRequestForm,
               type: :model do
  subject(:form) do
    described_class.new(application_form:, comment:, has_supporting_documents:)
  end

  let(:application_form) { create(:application_form, :with_assessment) }

  describe "validations" do
    let(:comment) { "" }
    let(:has_supporting_documents) { "" }

    it { is_expected.to validate_presence_of(:application_form) }

    it do
      expect(subject).to validate_presence_of(:comment).with_message(
        "Enter your reasoning for a decision review",
      )
    end

    it do
      expect(subject).to validate_presence_of(
        :has_supporting_documents,
      ).with_message(
        "Select if you need to upload any supporting evidence for your request",
      )
    end
  end

  describe "#save" do
    let(:comment) { "Decline was a mistake." }
    let(:has_supporting_documents) { "true" }

    it "creates a new DecisionReviewRequest" do
      expect { form.save(validate: true) }.to change {
        application_form.assessment.decision_review_request
      }.from(nil)

      expect(application_form.assessment.decision_review_request.comment).to eq(
        comment,
      )
      expect(
        application_form
          .assessment
          .decision_review_request
          .has_supporting_documents,
      ).to be true
    end
  end
end
