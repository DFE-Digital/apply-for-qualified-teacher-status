RSpec.describe TeacherInterface::NameAndDateOfBirthForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:application_form) }
  end

  let(:application_form) { build(:application_form) }

  describe "#valid?" do
    subject(:valid?) { form.valid? }

    let(:form) do
      described_class.new(
        application_form:,
        given_names:,
        family_name:,
        date_of_birth:
      )
    end
    let(:given_names) { "" }
    let(:family_name) { "" }
    let(:date_of_birth) { "" }

    it { is_expected.to be true }

    context "when date of birth is less than 18 years ago" do
      let(:date_of_birth) { Time.zone.now }

      it { is_expected.to be false }
    end

    context "when date of birth is greater than 100 years ago" do
      let(:date_of_birth) { Date.new(1900, 1, 1) }

      it { is_expected.to be false }
    end
  end

  describe "#save" do
    let(:form) do
      described_class.new(
        application_form:,
        given_names: "Given",
        family_name: "Family",
        date_of_birth: Date.new(2000, 1, 1)
      )
    end

    before { form.save }

    it "saves the application form" do
      expect(application_form.given_names).to eq("Given")
      expect(application_form.family_name).to eq("Family")
      expect(application_form.date_of_birth).to eq(Date.new(2000, 1, 1))
    end
  end
end
