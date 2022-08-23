RSpec.describe TeacherInterface::RegistrationNumberForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:application_form) }
  end

  let(:application_form) { build(:application_form) }

  describe "#valid?" do
    subject(:valid?) { form.valid? }

    let(:form) { described_class.new(application_form:, registration_number:) }
    let(:registration_number) { "" }

    it { is_expected.to be true }
  end

  describe "#save" do
    let(:form) do
      described_class.new(application_form:, registration_number: "ABC")
    end

    before { form.save }

    it "saves the application form" do
      expect(application_form.registration_number).to eq("ABC")
    end
  end
end
