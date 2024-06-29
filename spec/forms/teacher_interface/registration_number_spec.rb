require "rails_helper"

RSpec.describe TeacherInterface::RegistrationNumberForm, type: :model do
  subject(:form) do
    described_class.new(application_form:, registration_number:)
  end

  let(:application_form) { build(:application_form) }

  describe "validations" do
    let(:registration_number) { "" }

    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.not_to validate_presence_of(:registration_number) }
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    context "with a present registration number" do
      let(:registration_number) { "ABC" }

      it "sets the registration number to the string" do
        expect { save }.to change(application_form, :registration_number).to(
          "ABC",
        )
      end
    end

    context "with a blank registration number" do
      let(:registration_number) { "" }

      it "sets the registration number to blank" do
        expect { save }.to change(application_form, :registration_number).to("")
      end
    end

    context "with a nil registration number" do
      let(:registration_number) { nil }

      it "sets the registration number to blank" do
        expect { save }.to change(application_form, :registration_number).to("")
      end
    end
  end
end
