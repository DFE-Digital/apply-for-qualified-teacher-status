# frozen_string_literal: true

# == Schema Information
#
# Table name: suitability_records
#
#  id            :bigint           not null, primary key
#  archive_note  :text             default(""), not null
#  archived_at   :datetime
#  country_code  :text             default(""), not null
#  date_of_birth :date
#  note          :text             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :bigint           not null
#
# Indexes
#
#  index_suitability_records_on_created_by_id  (created_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => staff.id)
#
require "rails_helper"

RSpec.describe SuitabilityRecord, type: :model do
  subject(:suitability_record) { build(:suitability_record) }

  describe "validations" do
    it { is_expected.to be_valid }

    it { is_expected.to validate_presence_of(:note) }
    it { is_expected.not_to validate_presence_of(:archive_note) }

    context "when archived" do
      before { suitability_record.archived_at = Time.zone.now }

      it { is_expected.to validate_presence_of(:archive_note) }
    end
  end
end
