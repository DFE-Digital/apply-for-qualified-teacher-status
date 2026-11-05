# frozen_string_literal: true

# == Schema Information
#
# Table name: decision_review_requests
#
#  id                       :bigint           not null, primary key
#  comment                  :text             default(""), not null
#  has_supporting_documents :boolean
#  received_at              :datetime
#  review_note              :text             default(""), not null
#  review_passed            :boolean
#  reviewed_at              :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  assessment_id            :bigint           not null
#
# Indexes
#
#  index_decision_review_requests_on_assessment_id  (assessment_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#
require "rails_helper"

RSpec.describe DecisionReviewRequest, type: :model do
  subject(:decision_review_request) { create(:decision_review_request) }

  it_behaves_like "a documentable"

  describe "validations" do
    it { is_expected.not_to validate_presence_of(:received_at) }
  end

  describe "#completed?" do
    subject(:completed?) { decision_review_request.completed? }

    let(:decision_review_request) do
      build(:decision_review_request, comment:, has_supporting_documents:)
    end
    let(:comment) { "Example decision review reason" }
    let(:has_supporting_documents) { nil }
    let(:document_completed) { false }
    let(:document) { instance_double(Document, completed?: document_completed) }

    before do
      allow(decision_review_request).to receive(
        :decision_review_evidence_document,
      ).and_return(document)
    end

    context "without a supporting-evidence choice" do
      it { is_expected.to be false }
    end

    context "without supporting evidence" do
      let(:has_supporting_documents) { false }

      it { is_expected.to be true }

      context "without a comment" do
        let(:comment) { "" }

        it { is_expected.to be false }
      end
    end

    context "with supporting evidence" do
      let(:has_supporting_documents) { true }

      context "when the document is incomplete" do
        it { is_expected.to be false }
      end

      context "when the document is complete" do
        let(:document_completed) { true }

        it { is_expected.to be true }

        context "without a comment" do
          let(:comment) { "" }

          it { is_expected.to be false }
        end
      end
    end
  end

  describe "#received!" do
    let(:call) { subject.received! }

    it "sets the received at date" do
      freeze_time do
        expect { call }.to change(subject, :received_at).from(nil).to(
          Time.zone.now,
        )
      end
    end
  end

  describe "#review_status" do
    it "is accepted when passed is true" do
      subject.review_passed = true
      expect(subject.review_status).to eq("accepted")
    end

    it "is rejected when passed is false" do
      subject.review_passed = false
      expect(subject.review_status).to eq("rejected")
    end

    it "is not started if not reviewed" do
      expect(subject.review_status).to eq("not_started")
    end
  end

  describe "#after_received" do
    let(:after_received) { subject.after_received(user: "User") }

    let(:application_form) { decision_review_request.application_form }

    it "delivers the decision_review_requested email" do
      expect { after_received }.to have_enqueued_mail(
        TeacherMailer,
        :decision_review_received,
      ).with(params: { application_form: }, args: [])
    end
  end

  describe "#after_reviewed" do
    let(:after_reviewed) { subject.after_reviewed(user: "User") }

    let(:application_form) { decision_review_request.application_form }

    before { allow(RollbackAssessment).to receive(:call) }

    it "triggers decision review reviewed email" do
      expect { after_reviewed }.to have_enqueued_mail(
        TeacherMailer,
        :decision_review_reviewed,
      ).with(params: { application_form:, decision_review_request: }, args: [])
    end

    context "when the review has passed" do
      before { decision_review_request.review_passed = true }

      it "rollsback assessment" do
        after_reviewed

        expect(RollbackAssessment).to have_received(:call).with(
          assessment: decision_review_request.assessment,
          user: "User",
        )
      end
    end

    context "when the review has not passed" do
      before { decision_review_request.review_passed = false }

      it "does not rollback assessment" do
        after_reviewed

        expect(RollbackAssessment).not_to have_received(:call)
      end
    end
  end
end
