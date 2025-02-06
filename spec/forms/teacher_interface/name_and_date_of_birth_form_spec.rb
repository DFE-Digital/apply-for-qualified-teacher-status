# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::NameAndDateOfBirthForm, type: :model do
  subject(:form) do
    described_class.new(
      application_form:,
      given_names:,
      family_name:,
      date_of_birth:,
    )
  end

  let(:application_form) do
    build(:application_form, requires_passport_as_identity_proof: false)
  end

  describe "validations" do
    let(:given_names) { "" }
    let(:family_name) { "" }
    let(:date_of_birth) { "" }

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
  end

  describe "#save" do
    let(:given_names) { "Given" }
    let(:family_name) { "Family" }
    let(:date_of_birth) { { 1 => 2000, 2 => 1, 3 => 1 } }

    before { form.save(validate: true) }

    it "saves the application form" do
      expect(application_form.given_names).to eq("Given")
      expect(application_form.family_name).to eq("Family")
      expect(application_form.date_of_birth).to eq(Date.new(2000, 1, 1))
    end
  end
end
