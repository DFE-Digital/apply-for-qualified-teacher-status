# frozen_string_literal: true

# == Schema Information
#
# Table name: professional_standing_requests
#
#  id                    :bigint           not null, primary key
#  failure_assessor_note :string           default(""), not null
#  location_note         :text             default(""), not null
#  passed                :boolean
#  received_at           :datetime
#  reviewed_at           :datetime
#  state                 :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  assessment_id         :bigint           not null
#
# Indexes
#
#  index_professional_standing_requests_on_assessment_id  (assessment_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#
require "rails_helper"

RSpec.describe ProfessionalStandingRequest, type: :model do
  it_behaves_like "a requestable" do
    subject { create(:professional_standing_request, :receivable) }
  end

  it_behaves_like "a locatable"

  describe "validations" do
    context "when received" do
      subject { build(:professional_standing_request, :received) }

      it { is_expected.to validate_presence_of(:location_note) }
    end
  end

  describe "#expires_after" do
    let(:professional_standing_request) do
      create(:professional_standing_request)
    end

    subject(:expires_after) { professional_standing_request.expires_after }

    it { is_expected.to be_nil }

    context "when teaching authority provides written statement" do
      before do
        professional_standing_request.application_form.update!(
          teaching_authority_provides_written_statement: true,
        )
      end

      it { is_expected.to eq(18.weeks) }
    end
  end
end
