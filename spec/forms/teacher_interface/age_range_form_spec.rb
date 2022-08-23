RSpec.describe TeacherInterface::AgeRangeForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:application_form) }
  end

  let(:application_form) { build(:application_form) }

  describe "#valid?" do
    subject(:valid?) { form.valid? }

    let(:form) { described_class.new(application_form:, minimum:, maximum:) }

    context "when the fields are blank" do
      let(:minimum) { "" }
      let(:maximum) { "" }

      it { is_expected.to be true }
    end

    context "when the fields are numbers" do
      let(:minimum) { "7" }
      let(:maximum) { "11" }

      it { is_expected.to be true }
    end

    context "when age range max is less than age range min" do
      let(:minimum) { "11" }
      let(:maximum) { "7" }

      it { is_expected.to be false }
    end
  end

  describe "#save" do
    let(:form) do
      described_class.new(application_form:, minimum: 7, maximum: 11)
    end

    before { form.save }

    it "saves the application form" do
      expect(application_form.age_range_min).to eq(7)
      expect(application_form.age_range_max).to eq(11)
    end
  end
end
