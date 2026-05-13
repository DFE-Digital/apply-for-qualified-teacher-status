# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::DecisionReviewRequestReviewForm,
               type: :model do
  subject(:form) do
    described_class.new(
      decision_review_request:,
      review_passed:,
      review_passed_note:,
      review_failed_note:,
    )
  end

  let(:decision_review_request) { create(:received_decision_review_request) }
  let(:review_passed) { nil }
  let(:review_passed_note) { "" }
  let(:review_failed_note) { "" }

  describe "validations" do
    it do
      expect(subject).to allow_values(true, false).for(
        :review_passed,
      ).with_message(
        "Select if the applicant has provided enough evidence to change the decline decision",
      )
    end

    context "when passed" do
      let(:review_passed) { "true" }

      it { is_expected.to validate_presence_of(:review_passed_note) }
      it { is_expected.not_to validate_presence_of(:review_failed_note) }
    end

    context "when not passed" do
      let(:review_passed) { "false" }

      it { is_expected.not_to validate_presence_of(:review_passed_note) }
      it { is_expected.to validate_presence_of(:review_failed_note) }
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    context "when review_passed is true" do
      let(:review_passed) { "true" }
      let(:review_passed_note) { "Everything was correct." }

      it "updates review passed field" do
        expect { save }.to change(decision_review_request, :review_passed).from(
          nil,
        ).to(true)
      end

      it "updates review note field" do
        expect { save }.to change(decision_review_request, :review_note).from(
          "",
        ).to(review_passed_note)
      end
    end

    context "when passed is false" do
      let(:review_passed) { "false" }
      let(:review_failed_note) { "You did not provide enough evidence." }

      it "updates review passed field" do
        expect { save }.to change(decision_review_request, :review_passed).from(
          nil,
        ).to(false)
      end

      it "updates review note field" do
        expect { save }.to change(decision_review_request, :review_note).from(
          "",
        ).to(review_failed_note)
      end
    end
  end
end
