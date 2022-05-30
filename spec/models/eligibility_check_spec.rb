# == Schema Information
#
# Table name: eligibility_checks
#
#  id                :bigint           not null, primary key
#  completed_at      :datetime
#  country_code      :string
#  degree            :boolean
#  free_of_sanctions :boolean
#  qualification     :boolean
#  recognised        :boolean
#  teach_children    :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  region_id         :bigint
#
# Foreign Keys
#
#  fk_rails_...  (region_id => regions.id)
#
require "rails_helper"

RSpec.describe EligibilityCheck, type: :model do
  let(:eligibility_check) { EligibilityCheck.new }

  describe "#ineligible_reasons" do
    subject(:ineligible_reasons) { eligibility_check.ineligible_reasons }

    context "when free_of_sanctions is true" do
      before { eligibility_check.free_of_sanctions = true }

      it { is_expected.to_not include(:misconduct) }
    end

    context "when free_of_sanctions is false" do
      before { eligibility_check.free_of_sanctions = false }

      it { is_expected.to include(:misconduct) }
    end

    context "when recognised is true" do
      before { eligibility_check.recognised = true }

      it { is_expected.to_not include(:recognised) }
    end

    context "when recognised is false" do
      before { eligibility_check.recognised = false }

      it { is_expected.to include(:recognised) }
    end

    context "when teach_children is true" do
      before { eligibility_check.teach_children = true }

      it { is_expected.to_not include(:teach_children) }
    end

    context "when teach_children is false" do
      before { eligibility_check.teach_children = false }

      it { is_expected.to include(:teach_children) }
    end

    context "when qualification is true" do
      before { eligibility_check.qualification = true }

      it { is_expected.to_not include(:qualification) }
    end

    context "when qualification is false" do
      before { eligibility_check.qualification = false }

      it { is_expected.to include(:qualification) }
    end

    context "when degree is true" do
      before { eligibility_check.degree = true }

      it { is_expected.to_not include(:degree) }
    end

    context "when degree is false" do
      before { eligibility_check.degree = false }

      it { is_expected.to include(:degree) }
    end

    context "when country exists" do
      let(:country) { create(:country, :with_national_region) }

      before { eligibility_check.country_code = country.code }

      it { is_expected.to_not include(:country) }
    end

    context "when country doesn't exist" do
      before { eligibility_check.country_code = "ABC" }

      it { is_expected.to include(:country) }
    end
  end

  describe "#eligible?" do
    subject(:eligible?) { eligibility_check.eligible? }

    context "when not eligible" do
      it { is_expected.to be false }
    end

    context "when eligible" do
      let(:country) { create(:country, :with_national_region) }

      before do
        eligibility_check.free_of_sanctions = true
        eligibility_check.recognised = true
        eligibility_check.teach_children = true
        eligibility_check.qualification = true
        eligibility_check.degree = true
        eligibility_check.country_code = country.code
      end

      it { is_expected.to be true }
    end
  end

  describe "#country_eligibility_status" do
    subject(:country_eligibility_status) do
      eligibility_check.country_eligibility_status
    end

    context "when the country exists" do
      before { eligibility_check.country_code = create(:country).code }

      it { is_expected.to eq(:region) }
    end

    context "when the country exists and has a region" do
      before do
        eligibility_check.country_code =
          create(:country, :with_national_region).code
      end

      it { is_expected.to eq(:eligible) }
    end

    context "when the country exists and is legacy" do
      before { eligibility_check.country_code = create(:country, :legacy).code }

      it { is_expected.to eq(:legacy) }
    end

    context "when the country doesn't exist" do
      before { eligibility_check.country_code = "ABC" }

      it { is_expected.to be(:ineligible) }
    end
  end

  describe "#country_regions" do
    subject(:country_regions) { eligibility_check.country_regions }

    let(:country) { create(:country) }
    let(:region_1) { create(:region, name: "A", country:) }
    let(:region_2) { create(:region, name: "B", country:) }

    before { eligibility_check.country_code = country.code }

    it { is_expected.to eq([region_1, region_2]) }
  end

  describe "#eligible" do
    subject(:eligible) { described_class.eligible }

    let(:eligibility_check_1) { create(:eligibility_check) }
    let(:eligibility_check_2) { create(:eligibility_check, :eligible) }

    it { is_expected.to_not include(eligibility_check_1) }
    it { is_expected.to include(eligibility_check_2) }
  end

  describe ".complete" do
    subject(:complete) { described_class.complete }

    let!(:incomplete_check) { create(:eligibility_check) }
    let!(:complete_check) { create(:eligibility_check, :complete) }

    it { is_expected.to eq([complete_check]) }
  end

  describe ".ineligible" do
    subject(:ineligible) { described_class.ineligible }

    let!(:ineligible_check) { create(:eligibility_check, :ineligible) }
    let!(:eligible_check) { create(:eligibility_check, :eligible) }

    it { is_expected.to eq([ineligible_check]) }
  end

  describe "#complete!" do
    subject(:complete!) { eligibility_check.complete! }

    let(:eligibility_check) { create(:eligibility_check, :eligible) }

    it "sets the completed_at attribute" do
      freeze_time do
        expect { complete! }.to change(eligibility_check, :completed_at).from(
          nil
        ).to(Time.current)
      end
    end
  end
end
