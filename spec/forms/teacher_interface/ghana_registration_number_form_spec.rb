# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::GhanaRegistrationNumberForm, type: :model do
  subject(:form) do
    described_class.new(
      application_form:,
      license_number_part_one:,
      license_number_part_two:,
      license_number_part_three:,
    )
  end

  let(:application_form) { build(:application_form) }

  describe "validations" do
    let(:license_number_part_one) { "" }
    let(:license_number_part_two) { "" }
    let(:license_number_part_three) { "" }

    it { is_expected.to validate_presence_of(:application_form) }

    context "with empty parts" do
      it { is_expected.to be_invalid }
    end

    context "with license number parts having invalid number of characters" do
      let(:license_number_part_one) { "A" }
      let(:license_number_part_two) { "1" }
      let(:license_number_part_three) { "244444444" }

      it { is_expected.to be_invalid }
    end

    context "with license number parts having invalid format of characters" do
      let(:license_number_part_one) { "11" }
      let(:license_number_part_two) { "AB&DSE" }
      let(:license_number_part_three) { "1%NB" }

      it { is_expected.to be_invalid }
    end

    context "with license number parts having spaces in the end" do
      let(:license_number_part_one) { " PT " }
      let(:license_number_part_two) { "123456 " }
      let(:license_number_part_three) { " 1234" }

      it { is_expected.to be_valid }
    end

    context "with valid parts" do
      let(:license_number_part_one) { "PT" }
      let(:license_number_part_two) { "123456" }
      let(:license_number_part_three) { "1234" }

      it { is_expected.to be_valid }
    end
  end

  describe "#save" do
    context "with valid parts" do
      subject(:save) { form.save(validate: true) }

      let(:license_number_part_one) { "PT" }
      let(:license_number_part_two) { "123456" }
      let(:license_number_part_three) { "1234" }

      it "sets the registration number to the string" do
        expect { save }.to change(application_form, :registration_number).to(
          "PT/123456/1234",
        )
      end
    end

    context "with license number parts having spaces in the end" do
      subject(:save) { form.save(validate: true) }

      let(:license_number_part_one) { " PT " }
      let(:license_number_part_two) { "123456 " }
      let(:license_number_part_three) { " 1234" }

      it "sets the registration number to the string without spaces" do
        expect { save }.to change(application_form, :registration_number).to(
          "PT/123456/1234",
        )
      end
    end

    context "with invalid parts" do
      subject(:save) { form.save(validate: false) }

      let(:license_number_part_one) { "P2" }
      let(:license_number_part_two) { "123%56" }
      let(:license_number_part_three) { "1^634" }

      it "sets the registration number to the string" do
        expect { save }.to change(application_form, :registration_number).to(
          "P2/123%56/1^634",
        )
      end

      context "when all parts are empty" do
        let(:license_number_part_one) { "" }
        let(:license_number_part_two) { "" }
        let(:license_number_part_three) { "" }

        before do
          application_form.update(registration_number: "PT/123456/1234")
        end

        it "sets the registration number to nil" do
          expect { save }.to change(application_form, :registration_number).to(
            nil,
          )
        end
      end

      context "when some parts are empty" do
        let(:license_number_part_one) { "PT" }
        let(:license_number_part_two) { "" }
        let(:license_number_part_three) { "111" }

        it "sets the registration number to nil" do
          expect { save }.to change(application_form, :registration_number).to(
            "PT//111",
          )
        end
      end
    end
  end
end
