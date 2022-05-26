# == Schema Information
#
# Table name: eligibility_checks
#
#  id                :bigint           not null, primary key
#  degree            :boolean
#  country_code      :string
#  free_of_sanctions :boolean
#  qualification     :boolean
#  recognised        :boolean
#  teach_children    :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
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
      let(:country) { create(:country) }

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
      let(:country) { create(:country) }

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

  describe "#country" do
    subject(:country) { eligibility_check.country }

    context "when country_code exists" do
      let(:country) { create(:country) }

      before { eligibility_check.country_code = country.code }

      it { is_expected.to eq(country) }
    end

    context "when country_code doesn't exist" do
      before { eligibility_check.country_code = "ABC" }

      it { is_expected.to be_nil }
    end
  end

  describe "#country_eligibility_status" do
    subject(:country_eligibility_status) do
      eligibility_check.country_eligibility_status
    end

    context "when the country exists" do
      before { eligibility_check.country_code = create(:country).code }

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
end
