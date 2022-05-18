# == Schema Information
#
# Table name: eligibility_checks
#
#  id                :bigint           not null, primary key
#  free_of_sanctions :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  recognised        :boolean
#  teach_children    :boolean
#
require "rails_helper"

RSpec.describe EligibilityCheck, type: :model do
  describe "#ineligible_reason" do
    subject(:ineligible_reason) { eligibility_check.ineligible_reason }

    let(:eligibility_check) { EligibilityCheck.new }

    context "when free_of_sanctions is true" do
      before { eligibility_check.free_of_sanctions = true }

      it { is_expected.to be_nil }
    end

    context "when free_of_sanctions is false" do
      before { eligibility_check.free_of_sanctions = false }

      it { is_expected.to eq(:misconduct) }
    end

    context "when recognised is true" do
      before { eligibility_check.recognised = true }

      it { is_expected.to be_nil }
    end

    context "when recognised is false" do
      before { eligibility_check.recognised = false }

      it { is_expected.to eq(:recognised) }
    end

    context "when teach_children is true" do
      before { eligibility_check.teach_children = true }

      it { is_expected.to be_nil }
    end

    context "when teach_children is false" do
      before { eligibility_check.teach_children = false }

      it { is_expected.to eq(:teach_children) }
    end

    context "when qualification is true" do
      before { eligibility_check.qualification = true }

      it { is_expected.to be_nil }
    end

    context "when qualification is false" do
      before { eligibility_check.qualification = false }

      it { is_expected.to eq(:qualification) }
    end
  end
end
