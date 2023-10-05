# frozen_string_literal: true

# == Schema Information
#
# Table name: reference_requests
#
#  id                              :bigint           not null, primary key
#  additional_information_response :text             default(""), not null
#  children_comment                :text             default(""), not null
#  children_response               :boolean
#  contact_comment                 :text             default(""), not null
#  contact_job                     :string           default(""), not null
#  contact_name                    :string           default(""), not null
#  contact_response                :boolean
#  dates_comment                   :text             default(""), not null
#  dates_response                  :boolean
#  expired_at                      :datetime
#  failure_assessor_note           :string           default(""), not null
#  hours_comment                   :text             default(""), not null
#  hours_response                  :boolean
#  lessons_comment                 :text             default(""), not null
#  lessons_response                :boolean
#  misconduct_comment              :text             default(""), not null
#  misconduct_response             :boolean
#  passed                          :boolean
#  received_at                     :datetime
#  reports_comment                 :text             default(""), not null
#  reports_response                :boolean
#  requested_at                    :datetime
#  reviewed_at                     :datetime
#  satisfied_comment               :text             default(""), not null
#  satisfied_response              :boolean
#  slug                            :string           not null
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
  subject(:reference_request) { create(:reference_request) }

  it_behaves_like "a remindable"

  it_behaves_like "a requestable" do
    subject { create(:reference_request, :receivable) }
  end

  it { is_expected.to have_secure_token(:slug) }

  describe "associations" do
    it { is_expected.to belong_to(:work_history) }
  end

  describe "scopes" do
    describe "#remindable" do
      subject(:remindable) { described_class.remindable }

      let(:expected) do
        create(
          :reference_request,
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
          :reference_request,
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

  describe "#expires_after" do
    subject(:expires_after) { described_class.new.expires_after }
    it { is_expected.to eq(6.weeks) }
  end
end
