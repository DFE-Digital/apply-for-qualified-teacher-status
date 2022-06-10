require "rails_helper"

RSpec.describe EligibilityInterface::MisconductForm, type: :model do
  it { is_expected.to validate_presence_of(:eligibility_check) }
  it do
    is_expected.to validate_inclusion_of(:free_of_sanctions).in_array(
      [true, false]
    )
  end

  describe "#valid?" do
    subject(:valid) { form.valid? }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) { described_class.new(eligibility_check:, free_of_sanctions:) }
    let(:free_of_sanctions) { "true" }

    it { is_expected.to be_truthy }

    context "when free_of_sanctions is blank" do
      let(:free_of_sanctions) { "" }

      it { is_expected.to be_falsy }
    end
  end

  describe "#save" do
    subject(:save!) { form.save }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) do
      described_class.new(eligibility_check:, free_of_sanctions: true)
    end

    it "saves the eligibility check" do
      save!
      expect(eligibility_check.free_of_sanctions).to be_truthy
    end
  end
end
