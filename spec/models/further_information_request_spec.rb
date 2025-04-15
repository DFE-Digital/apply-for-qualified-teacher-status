# frozen_string_literal: true

# == Schema Information
#
# Table name: further_information_requests
#
#  id                                          :bigint           not null, primary key
#  expired_at                                  :datetime
#  received_at                                 :datetime
#  requested_at                                :datetime
#  review_note                                 :string           default(""), not null
#  review_passed                               :boolean
#  reviewed_at                                 :datetime
#  working_days_assessment_started_to_creation :integer
#  working_days_received_to_recommendation     :integer
#  working_days_since_received                 :integer
#  created_at                                  :datetime         not null
#  updated_at                                  :datetime         not null
#  assessment_id                               :bigint           not null
#
# Indexes
#
#  index_further_information_requests_on_assessment_id  (assessment_id)
#
require "rails_helper"

RSpec.describe FurtherInformationRequest do
  subject(:model) { further_information_request }

  let(:further_information_request) { create(:further_information_request) }

  it_behaves_like "a remindable" do
    subject { create(:requested_further_information_request) }
  end

  it_behaves_like "a requestable"

  describe "scopes" do
    describe "#remindable" do
      subject(:remindable) { described_class.remindable }

      let(:expected) do
        create(
          :further_information_request,
          :requested,
          assessment:
            create(
              :assessment,
              application_form: create(:application_form, :submitted),
            ),
        )
      end

      before do
        create(
          :further_information_request,
          assessment:
            create(
              :assessment,
              application_form: create(:application_form, :awarded),
            ),
        )
      end

      it { is_expected.to eq([expected]) }
    end
  end

  describe "#first_request?" do
    subject(:first_request?) { further_information_request.first_request? }

    let(:further_information_request) do
      create(:requested_further_information_request)
    end

    context "when the only further information request within assessment" do
      it { is_expected.to be true }
    end

    context "when one other further information request exists within assesment requested previously" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be false }
    end

    context "when one other further information request exists within assesment requested after" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be true }
    end

    context "when two other further information request exists within assesment requested previously" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 2.days,
               assessment: further_information_request.assessment

        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be false }
    end

    context "when two other further information request exists within assesment requested after" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 2.days,
               assessment: further_information_request.assessment

        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be true }
    end

    context "when two other further information request exists within assesment requested before and after" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 2.days,
               assessment: further_information_request.assessment

        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be false }
    end
  end

  describe "#second_request?" do
    subject(:second_request?) { further_information_request.second_request? }

    let(:further_information_request) do
      create(:requested_further_information_request)
    end

    context "when the only further information request within assessment" do
      it { is_expected.to be false }
    end

    context "when one other further information request exists within assesment requested previously" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be true }
    end

    context "when one other further information request exists within assesment requested after" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be false }
    end

    context "when two other further information request exists within assesment requested previously" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 2.days,
               assessment: further_information_request.assessment

        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be false }
    end

    context "when two other further information request exists within assesment requested after" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 2.days,
               assessment: further_information_request.assessment

        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be false }
    end

    context "when two other further information request exists within assesment requested before and after" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 2.days,
               assessment: further_information_request.assessment

        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be true }
    end
  end

  describe "#third_request?" do
    subject(:third_request?) { further_information_request.third_request? }

    let(:further_information_request) do
      create(:requested_further_information_request)
    end

    context "when the only further information request within assessment" do
      it { is_expected.to be false }
    end

    context "when one other further information request exists within assesment requested previously" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be false }
    end

    context "when one other further information request exists within assesment requested after" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be false }
    end

    context "when two other further information request exists within assesment requested previously" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 2.days,
               assessment: further_information_request.assessment

        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be true }
    end

    context "when two other further information request exists within assesment requested after" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 2.days,
               assessment: further_information_request.assessment

        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be false }
    end

    context "when two other further information request exists within assesment requested before and after" do
      before do
        create :requested_further_information_request,
               requested_at: further_information_request.requested_at - 2.days,
               assessment: further_information_request.assessment

        create :requested_further_information_request,
               requested_at: further_information_request.requested_at + 1.day,
               assessment: further_information_request.assessment
      end

      it { is_expected.to be false }
    end
  end
end
