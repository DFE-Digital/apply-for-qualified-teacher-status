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

    it "delivers the decision_review_requested email" do
      expect { after_received }.to have_enqueued_mail(
        TeacherMailer,
        :decision_review_received,
      ).with(
        params: {
          application_form: decision_review_request.application_form,
        },
        args: [],
      )
    end
  end

  describe "#after_reviewed" do
    let(:after_reviewed) { subject.after_reviewed(user: "User") }

    before { allow(RollbackAssessment).to receive(:call) }

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
