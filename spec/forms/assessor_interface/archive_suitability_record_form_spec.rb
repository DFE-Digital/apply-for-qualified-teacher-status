# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ArchiveSuitabilityRecordForm, type: :model do
  subject(:form) { described_class.new(suitability_record:, user:, note:) }

  let(:suitability_record) { create(:suitability_record) }
  let(:user) { create(:staff) }
  let(:note) { "A note." }

  describe "validations" do
    it { is_expected.to validate_presence_of(:suitability_record) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:note) }
  end

  describe "#save" do
    subject(:save) { form.save }

    it "updates the fields" do
      expect(save).to be true

      expect(suitability_record).to be_archived
      expect(suitability_record.archive_note).to eq("A note.")
    end
  end
end
