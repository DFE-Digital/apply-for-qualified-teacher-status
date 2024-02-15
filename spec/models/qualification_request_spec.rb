# frozen_string_literal: true

# == Schema Information
#
# Table name: qualification_requests
#
#  id                                   :bigint           not null, primary key
#  consent_method                       :string           default("unknown"), not null
#  consent_received_at                  :datetime
#  consent_requested_at                 :datetime
#  expired_at                           :datetime
#  location_note                        :text             default(""), not null
#  received_at                          :datetime
#  requested_at                         :datetime
#  review_note                          :string           default(""), not null
#  review_passed                        :boolean
#  reviewed_at                          :datetime
#  unsigned_consent_document_downloaded :boolean          default(FALSE), not null
#  verified_at                          :datetime
#  verify_note                          :text             default(""), not null
#  verify_passed                        :boolean
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  assessment_id                        :bigint           not null
#  qualification_id                     :bigint           not null
#
# Indexes
#
#  index_qualification_requests_on_assessment_id     (assessment_id)
#  index_qualification_requests_on_qualification_id  (qualification_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#  fk_rails_...  (qualification_id => qualifications.id)
#
require "rails_helper"

RSpec.describe QualificationRequest, type: :model do
  subject(:qualification_request) { create(:qualification_request) }

  it_behaves_like "a documentable"

  it_behaves_like "a requestable" do
    subject { create(:qualification_request, :receivable) }
  end

  describe "validations" do
    it { is_expected.to_not validate_presence_of(:consent_requested_at) }
    it { is_expected.to_not validate_presence_of(:consent_received_at) }

    context "when received" do
      subject { build(:qualification_request, :received) }

      it { is_expected.to_not validate_presence_of(:location_note) }
    end
  end

  describe "#expires_from" do
    subject(:expires_from) { qualification_request.expires_from }

    context "when consent has been requested" do
      let(:qualification_request) do
        create(
          :qualification_request,
          consent_requested_at: Date.new(2020, 1, 1),
        )
      end

      it { is_expected.to eq(Date.new(2020, 1, 1)) }
    end

    context "when verification has been requested" do
      let(:qualification_request) do
        create(
          :qualification_request,
          consent_requested_at: Date.new(2020, 1, 1),
          requested_at: Date.new(2021, 1, 1),
        )
      end

      it { is_expected.to eq(Date.new(2021, 1, 1)) }
    end
  end

  describe "#expires_after" do
    subject(:expires_after) { qualification_request.expires_after }

    context "when consent has been requested" do
      let(:qualification_request) do
        create(:qualification_request, :consent_requested)
      end

      it { is_expected.to eq(6.weeks) }
    end

    context "when verification has been requested" do
      let(:qualification_request) { create(:qualification_request, :requested) }

      it { is_expected.to eq(6.weeks) }
    end
  end

  describe "#consent_requested!" do
    let(:call) { subject.consent_requested! }

    it "sets the consent requested at date" do
      freeze_time do
        expect { call }.to change(subject, :consent_requested_at).from(nil).to(
          Time.zone.now,
        )
      end
    end
  end

  describe "#consent_received!" do
    let(:call) { subject.consent_received! }

    it "sets the consent received at date" do
      freeze_time do
        expect { call }.to change(subject, :consent_received_at).from(nil).to(
          Time.zone.now,
        )
      end
    end
  end
end
