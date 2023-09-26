# frozen_string_literal: true

# == Schema Information
#
# Table name: qualification_requests
#
#  id                    :bigint           not null, primary key
#  failure_assessor_note :string           default(""), not null
#  location_note         :text             default(""), not null
#  passed                :boolean
#  received_at           :datetime
#  requested_at          :datetime
#  reviewed_at           :datetime
#  state                 :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  assessment_id         :bigint           not null
#  qualification_id      :bigint           not null
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
  it_behaves_like "a requestable" do
    subject { create(:qualification_request, :receivable) }
  end

  describe "validations" do
    context "when received" do
      subject { build(:qualification_request, :received) }

      it { is_expected.to_not validate_presence_of(:location_note) }
    end
  end

  describe "#expires_after" do
    subject(:expires_after) { described_class.new.expires_after }
    it { is_expected.to eq(6.weeks) }
  end
end
