# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::SuitabilityRecordForm, type: :model do
  subject(:form) do
    described_class.new(
      suitability_record:,
      user:,
      aliases:,
      date_of_birth:,
      emails:,
      location:,
      name:,
      note:,
      references:,
    )
  end

  let(:suitability_record) { SuitabilityRecord.new }
  let(:user) { create(:staff) }

  describe "validations" do
    let(:aliases) { [] }
    let(:date_of_birth) { nil }
    let(:emails) { [] }
    let(:location) { nil }
    let(:name) { nil }
    let(:note) { nil }
    let(:references) { [] }

    it { is_expected.to validate_presence_of(:suitability_record) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:date_of_birth) }
    it { is_expected.to validate_presence_of(:location) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:note) }
  end

  describe "#save" do
    subject(:save) { form.save }

    let(:aliases) { ["Alternative Name"] }
    let(:date_of_birth) { { 1 => 1990, 2 => 1, 3 => 1 } }
    let(:emails) { %w[email1@example.com email2@example.com] }
    let(:location) { "country:FR" }
    let(:name) { "Main Name" }
    let(:note) { "This is a note." }
    let(:references) { [create(:application_form).reference] }

    it "saves the fields" do
      expect(save).to be true

      expect(suitability_record.persisted?).to be true

      expect(suitability_record.names.count).to eq(2)
      expect(suitability_record.names.first.value).to eq("Main Name")
      expect(suitability_record.names.second.value).to eq("Alternative Name")

      expect(suitability_record.date_of_birth).to eq(Date.new(1990, 1, 1))

      expect(suitability_record.emails.count).to eq(2)
      expect(suitability_record.emails.first.value).to eq("email1@example.com")
      expect(suitability_record.emails.second.value).to eq("email2@example.com")

      expect(suitability_record.country_code).to eq("FR")

      expect(suitability_record.note).to eq("This is a note.")

      expect(suitability_record.application_forms.count).to eq(1)
    end
  end
end
