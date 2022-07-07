require "rails_helper"

RSpec.describe EligibilityInterface::CountryForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:eligibility_check) }
    it { is_expected.to validate_presence_of(:location) }
  end

  describe "#valid?" do
    subject(:valid) { form.valid? }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) do
      described_class.new(eligibility_check:, location: "country:GB")
    end

    it { is_expected.to be_truthy }
  end

  describe "#save" do
    subject(:save!) { form.save }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) do
      described_class.new(eligibility_check:, location: "country:GB")
    end

    it "saves the eligibility check" do
      save!
      expect(eligibility_check.country_code).to eq("GB")
    end
  end

  describe "#success_url" do
    subject(:success_url) { form.success_url }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) { described_class.new(eligibility_check:) }

    before { eligibility_check.country_code = country&.code }

    context "with an eligible country" do
      let(:country) { create(:country, :with_national_region) }

      it { is_expected.to eq("/eligibility/qualifications") }
    end

    context "with a legacy country" do
      let(:country) { create(:country, :with_legacy_region) }

      it { is_expected.to eq("/eligibility/eligible") }
    end

    context "with a multi-region country" do
      let(:country) { create(:country) }

      before { create_list(:region, 5, country:) }

      it { is_expected.to eq("/eligibility/region") }
    end

    context "with a non-eligible country" do
      let(:country) { nil }

      it { is_expected.to eq("/eligibility/ineligible") }
    end
  end
end
