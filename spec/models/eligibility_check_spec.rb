require 'rails_helper'

RSpec.describe EligibilityCheck, type: :model do
  describe '#ineligible_reason' do
    subject(:ineligible_reason) { eligibility_check.ineligible_reason }

    let(:eligibility_check) { EligibilityCheck.new }

    context 'when free_of_sanctions is true' do
      before do
        eligibility_check.free_of_sanctions = true
      end

      it { is_expected.to be_nil }
    end

    context 'when free_of_sanctions is false' do
      before do
        eligibility_check.free_of_sanctions = false
      end

      it { is_expected.to eq(:misconduct) }
    end
  end
end
