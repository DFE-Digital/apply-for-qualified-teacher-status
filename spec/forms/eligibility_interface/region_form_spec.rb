require "rails_helper"

RSpec.describe EligibilityInterface::RegionForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:eligibility_check) }
    it { is_expected.to validate_presence_of(:region_id) }
  end

  describe "#valid?" do
    subject(:valid) { form.valid? }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) { described_class.new(eligibility_check:, region_id:) }
    let(:region_id) { "10" }

    it { is_expected.to be_truthy }

    context "when region_id is blank" do
      let(:region_id) { "" }

      it { is_expected.to be_falsy }
    end
  end

  describe "#save" do
    subject(:save!) { form.save }

    let(:region) { create(:region) }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) { described_class.new(eligibility_check:, region_id: region.id) }

    it "saves the eligibility check" do
      save!
      expect(eligibility_check.region).to eq(region)
    end
  end

  describe "#success_url" do
    subject(:success_url) { form.success_url }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) { described_class.new(eligibility_check:) }

    before { eligibility_check.region = region }

    context "with an eligible country" do
      let(:region) { create(:region) }

      it { is_expected.to eq("/eligibility/qualifications") }
    end

    context "with a legacy country" do
      let(:region) { create(:region, :legacy) }

      it { is_expected.to eq("/eligibility/eligible") }
    end
  end
end
