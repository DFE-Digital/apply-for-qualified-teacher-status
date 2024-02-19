# frozen_string_literal: true

# == Schema Information
#
# Table name: qualification_requests
#
#  id               :bigint           not null, primary key
#  consent_method   :string           default("unknown"), not null
#  expired_at       :datetime
#  location_note    :text             default(""), not null
#  received_at      :datetime
#  requested_at     :datetime
#  review_note      :string           default(""), not null
#  review_passed    :boolean
#  reviewed_at      :datetime
#  verified_at      :datetime
#  verify_note      :text             default(""), not null
#  verify_passed    :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  assessment_id    :bigint           not null
#  qualification_id :bigint           not null
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

  it_behaves_like "a requestable" do
    subject { create(:qualification_request, :receivable) }
  end

  describe "columns" do
    it do
      is_expected.to define_enum_for(:consent_method)
        .with_values(
          none: "none",
          signed_ecctis: "signed_ecctis",
          signed_institution: "signed_institution",
          unknown: "unknown",
          unsigned: "unsigned",
        )
        .with_prefix
        .backed_by_column_of_type(:string)
    end
  end

  describe "validations" do
    context "when received" do
      subject { build(:qualification_request, :received) }

      it { is_expected.to_not validate_presence_of(:location_note) }
    end
  end

  describe "#expires_after" do
    subject(:expires_after) { qualification_request.expires_after }
    it { is_expected.to eq(6.weeks) }
  end
end
