require "rails_helper"

RSpec.describe TeacherInterface::RegistrationNumberForm, type: :model do
  let(:application_form) { build(:application_form) }

  subject(:form) do
    described_class.new(application_form:, registration_number:)
  end

  describe "validations" do
    let(:registration_number) { "" }

    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to validate_presence_of(:registration_number) }
  end

  describe "#save" do
    let(:registration_number) { "ABC" }

    before { form.save(validate: true) }

    it "saves the application form" do
      expect(application_form.registration_number).to eq("ABC")
    end
  end
end
