# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ApplicationFormDateOfBirthForm,
               type: :model do
  subject(:form) do
    described_class.new(application_form:, user:, date_of_birth:)
  end

  let(:application_form) { create(:application_form) }
  let(:user) { create(:staff) }
  let(:date_of_birth) { { 1 => 2000, 2 => 1, 3 => 1 } }

  describe "validations" do
    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to validate_presence_of(:user) }

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

        it { is_expected.to eq(["Enter a valid date of birth"]) }
      end

      context "when DOB more than 100 years ago" do
        let(:date_of_birth) { { 1 => 1800, 2 => 1, 3 => 1 } }

        it { expect(subject).to eq(["Enter a valid date of birth"]) }
      end

      context "when DOB has a 2 digit year" do
        let(:date_of_birth) { { 1 => 80, 2 => 1, 3 => 1 } }

        it do
          expect(subject).to eq(
            ["Enter a date of birth in the format 27 3 1980"],
          )
        end
      end

      context "when DOB is an invalid date" do
        let(:date_of_birth) { { 1 => 1990, 2 => 13, 3 => 40 } }

        it do
          expect(subject).to eq(
            ["Enter a date of birth in the format 27 3 1980"],
          )
        end
      end
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    it "calls the UpdateApplicationFormPersonalInformation service" do
      expect(UpdateApplicationFormPersonalInformation).to receive(:call).with(
        application_form:,
        user:,
        date_of_birth: Date.new(2000, 1, 1),
      )
      expect(save).to be true
    end
  end
end
