require "rails_helper"

RSpec.describe TeacherInterface::AgeRangeForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:application_form) }
  end

  let(:application_form) { build(:application_form) }

  describe "#valid?" do
    subject(:valid?) { form.valid? }

    let(:form) do
      described_class.new(application_form:, age_range_min:, age_range_max:)
    end
    let(:age_range_min) { "" }
    let(:age_range_max) { "" }

    it { is_expected.to be_truthy }

    context "when age range max is less than age range min" do
      let(:age_range_min) { "11" }
      let(:age_range_max) { "7" }

      it { is_expected.to be_falsy }
    end
  end

  describe "#save" do
    let(:form) do
      described_class.new(
        application_form:,
        age_range_min: 7,
        age_range_max: 11
      )
    end

    before { form.save }

    it "saves the eligibility check" do
      expect(application_form.age_range_min).to eq(7)
      expect(application_form.age_range_max).to eq(11)
    end
  end
end
