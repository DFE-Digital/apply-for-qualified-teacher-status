# frozen_string_literal: true

# == Schema Information
#
# Table name: professional_standing_requests
#
#  id            :bigint           not null, primary key
#  location_note :text             default(""), not null
#  passed        :boolean
#  received_at   :datetime
#  reviewed_at   :datetime
#  state         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  assessment_id :bigint           not null
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
    subject { build(:professional_standing_request, :receivable) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:assessment) }
  end

  describe "validations" do
    context "when received" do
      subject { build(:professional_standing_request, :received) }

      it { is_expected.to validate_presence_of(:location_note) }
    end
  end
end
