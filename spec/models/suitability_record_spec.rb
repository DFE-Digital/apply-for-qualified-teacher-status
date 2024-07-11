# frozen_string_literal: true

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
