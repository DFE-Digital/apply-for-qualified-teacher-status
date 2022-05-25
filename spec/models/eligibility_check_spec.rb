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

    context "when country_code is eligible" do
      before { eligibility_check.country_code = "GB" }

      it { is_expected.to_not include(:country) }
    end

    context "when country_code is ineligible" do
      before { eligibility_check.country_code = "INELIGIBLE" }

      it { is_expected.to include(:country) }
    end
  end

  describe "#eligible?" do
    subject(:eligible?) { eligibility_check.eligible? }

    context "when not eligible" do
      it { is_expected.to be false }
    end

    context "when eligible" do
      before do
        eligibility_check.free_of_sanctions = true
        eligibility_check.recognised = true
        eligibility_check.teach_children = true
        eligibility_check.qualification = true
        eligibility_check.degree = true
        eligibility_check.country_code = "GB"
      end

      it { is_expected.to be true }
    end
  end

  describe "#eligible_country_code?" do
    subject(:eligible_country_code?) do
      eligibility_check.eligible_country_code?
    end

    context "when country_code is eligible" do
      before { eligibility_check.country_code = "GB" }

      it { is_expected.to be true }
    end

    context "when country_code is not eligible" do
      before { eligibility_check.country_code = "ES" }

      it { is_expected.to be false }
    end
  end

  describe "#legacy_country_code?" do
    subject(:legacy_country_code?) { eligibility_check.legacy_country_code? }

    context "when country_code is legacy" do
      before { eligibility_check.country_code = "FR" }

      it { is_expected.to be true }
    end

    context "when country_code is not legacy" do
      before { eligibility_check.country_code = "ES" }

      it { is_expected.to be false }
    end
  end
end
