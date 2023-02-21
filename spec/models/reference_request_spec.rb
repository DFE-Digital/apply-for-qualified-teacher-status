# frozen_string_literal: true

# == Schema Information
#
# Table name: reference_requests
#
#  id                              :bigint           not null, primary key
#  additional_information_response :text             default(""), not null
#  children_response               :boolean
#  dates_response                  :boolean
#  hours_response                  :boolean
#  lessons_response                :boolean
#  passed                          :boolean
#  received_at                     :datetime
#  reports_response                :boolean
#  reviewed_at                     :datetime
#  slug                            :string           not null
#  state                           :string           not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  assessment_id                   :bigint           not null
#  work_history_id                 :bigint           not null
#
# Indexes
#
#  index_reference_requests_on_assessment_id    (assessment_id)
#  index_reference_requests_on_slug             (slug) UNIQUE
#  index_reference_requests_on_work_history_id  (work_history_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#  fk_rails_...  (work_history_id => work_histories.id)
#
require "rails_helper"

RSpec.describe ReferenceRequest do
  it_behaves_like "a requestable" do
    subject { build(:reference_request, :receivable) }
  end

  it { is_expected.to have_secure_token(:slug) }

  describe "associations" do
    it { is_expected.to belong_to(:assessment) }
    it { is_expected.to belong_to(:work_history) }
  end

  describe "validations" do
    context "when received" do
      subject { build(:reference_request, :received) }

      it { is_expected.to_not allow_value(nil).for(:dates_response) }

      it { is_expected.to_not allow_value(nil).for(:hours_response) }

      it { is_expected.to_not allow_value(nil).for(:children_response) }

      it { is_expected.to_not allow_value(nil).for(:lessons_response) }

      it { is_expected.to_not allow_value(nil).for(:reports_response) }

      it do
        is_expected.to_not validate_presence_of(
          :additional_information_response,
        )
      end
    end
  end

  describe "#responses_given?" do
    subject(:responses_given?) { reference_request.responses_given? }

    context "when requested" do
      let(:reference_request) { build(:reference_request, :requested) }
      it { is_expected.to be false }
    end

    context "when requested and all responses given" do
      let(:reference_request) do
        build(:reference_request, :requested, :receivable)
      end
      it { is_expected.to be true }
    end

    context "when received" do
      let(:reference_request) { build(:reference_request, :received) }
      it { is_expected.to be true }
    end
  end

  describe "#responses_valid?" do
    subject(:responses_valid?) { reference_request.responses_valid? }

    context "when no responses are given" do
      let(:reference_request) { build(:reference_request) }
      it { is_expected.to be false }
    end

    context "when all responses are valid" do
      let(:reference_request) { build(:reference_request, :responses_valid) }
      it { is_expected.to be true }
    end

    context "when all responses are invalid" do
      let(:reference_request) { build(:reference_request, :responses_invalid) }
      it { is_expected.to be false }
    end
  end
end
