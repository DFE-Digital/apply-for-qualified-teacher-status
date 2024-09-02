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
    let(:license_number_part_one) { '' }
    let(:license_number_part_two) { '' }
    let(:license_number_part_three) { '' }

    it { is_expected.to validate_presence_of(:application_form) }

    context "with empty parts" do
      it { is_expected.to be_invalid }
    end

    context "with license number parts having invalid number of characters" do
      let(:license_number_part_one) { 'A' }
      let(:license_number_part_two) { '1' }
      let(:license_number_part_three) { '244444444' }

      it { is_expected.to be_invalid }
    end

    context "with license number parts having invalid format of characters" do
      let(:license_number_part_one) { '11' }
      let(:license_number_part_two) { 'AB&DSE' }
      let(:license_number_part_three) { '1%NB' }

      it { is_expected.to be_invalid }
    end

    context "with valid parts" do
      let(:license_number_part_one) { 'PT' }
      let(:license_number_part_two) { '123456' }
      let(:license_number_part_three) { '1234' }

      it { is_expected.to be_valid }
    end
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    context "with valid parts" do
      let(:license_number_part_one) { 'PT' }
      let(:license_number_part_two) { '123456' }
      let(:license_number_part_three) { '1234' }

      it "sets the registration number to the string" do
        expect { save }.to change(application_form, :registration_number).to(
          "PT/123456/1234",
        )
      end
    end
  end
end
