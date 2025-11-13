# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::NameAndDateOfBirthForm, type: :model do
  subject(:form) do
    described_class.new(
      application_form:,
      given_names:,
      family_name:,
      date_of_birth:,
      national_insurance_number_part_one:,
      national_insurance_number_part_two:,
      national_insurance_number_part_three:,
    )
  end

  let(:application_form) do
    build(:application_form, requires_passport_as_identity_proof: false)
  end

  describe "validations" do
    let(:given_names) { "" }
    let(:family_name) { "" }
    let(:date_of_birth) { "" }
    let(:national_insurance_number_part_one) { "" }
    let(:national_insurance_number_part_two) { "" }
    let(:national_insurance_number_part_three) { "" }

    it { is_expected.to validate_presence_of(:application_form) }

    it do
      expect(subject).to validate_presence_of(:given_names).with_message(
        "Enter your given names as it appears on your ID documents",
      )
    end

    it do
      expect(subject).to validate_presence_of(:family_name).with_message(
        "Enter your surname as it appears on your ID documents",
      )
    end

    it { is_expected.to validate_presence_of(:date_of_birth) }

    it do
      expect(subject).not_to validate_presence_of(
        :national_insurance_number_part_one,
      )
      expect(subject).not_to validate_presence_of(
        :national_insurance_number_part_two,
      )
      expect(subject).not_to validate_presence_of(
        :national_insurance_number_part_three,
      )
    end

    context "when date of birth is more than 18 years ago but less than 100 years ago" do
      let(:date_of_birth) { { 1 => 1990, 2 => 1, 3 => 1 } }
      let(:given_names) { "given_name" }
      let(:family_name) { "family_name" }

      it { is_expected.to be_valid }
    end

    context "with an invalid DOB" do
      subject(:dob_error_message) { form.errors[:date_of_birth] }

      before { form.valid? }

      context "when DOB less than 18 years ago" do
        let(:date_of_birth) { { 1 => 2022, 2 => 1, 3 => 1 } }

        it { is_expected.to eq(["You must be 18 or over to use this service"]) }
      end

      context "when DOB more than 100 years ago" do
        let(:date_of_birth) { { 1 => 1800, 2 => 1, 3 => 1 } }

        it do
          expect(subject).to eq(
            ["Your date of birth cannot be that far in the past"],
          )
        end
      end

      context "when DOB has a 2 digit year" do
        let(:date_of_birth) { { 1 => 80, 2 => 1, 3 => 1 } }

        it do
          expect(subject).to eq(
            ["Enter your date of birth in the format 27 3 1980"],
          )
        end
      end

      context "when DOB is an invalid date" do
        let(:date_of_birth) { { 1 => 1990, 2 => 13, 3 => 40 } }

        it do
          expect(subject).to eq(
            ["Enter your date of birth in the format 27 3 1980"],
          )
        end
      end
    end

    context "when there national insurance number is present" do
      let(:date_of_birth) { { 1 => 1990, 2 => 1, 3 => 1 } }
      let(:given_names) { "given_name" }
      let(:family_name) { "family_name" }

      context "when valid national insurance number" do
        let(:national_insurance_number_part_one) { "QQ" }
        let(:national_insurance_number_part_two) { "123456" }
        let(:national_insurance_number_part_three) { "A" }

        it { is_expected.to be_valid }
      end

      context "when invalid national insurance number" do
        let(:national_insurance_number_part_one) { "QQ" }
        let(:national_insurance_number_part_two) { "A" }
        let(:national_insurance_number_part_three) { "A" }

        it { is_expected.not_to be_valid }
      end
    end
  end

  describe "#save" do
    let(:given_names) { "Given" }
    let(:family_name) { "Family" }
    let(:date_of_birth) { { 1 => 2000, 2 => 1, 3 => 1 } }
    let(:national_insurance_number_part_one) { "" }
    let(:national_insurance_number_part_two) { "" }
    let(:national_insurance_number_part_three) { "" }

    before { form.save(validate: true) }

    it "saves the application form" do
      expect(application_form.given_names).to eq("Given")
      expect(application_form.family_name).to eq("Family")
      expect(application_form.date_of_birth).to eq(Date.new(2000, 1, 1))
    end

    context "when national insurance number is present" do
      let(:national_insurance_number_part_one) { "QQ" }
      let(:national_insurance_number_part_two) { "123456" }
      let(:national_insurance_number_part_three) { "A" }

      it "saves the application form with national insurance number" do
        expect(application_form.given_names).to eq("Given")
        expect(application_form.family_name).to eq("Family")
        expect(application_form.date_of_birth).to eq(Date.new(2000, 1, 1))
        expect(application_form.national_insurance_number).to eq("QQ123456A")
      end
    end
  end
end
