require "rails_helper"

RSpec.describe TeacherInterface::NameAndDateOfBirthForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:application_form) }
  end

  let(:application_form) { build(:application_form) }

  let(:given_names) { "" }
  let(:family_name) { "" }
  let(:date_of_birth) { "" }

  describe "validations" do
    subject(:form) do
      described_class.new(
        application_form:,
        given_names:,
        family_name:,
        date_of_birth:,
      )
    end

    context "when date of birth and names are blank" do
      it { is_expected.to_not be_valid }
    end

    context "when date of birth is more than 18 years ago but less than 100 years ago" do
      let(:date_of_birth) { 20.years.ago }
      let(:given_names) { "given_name" }
      let(:family_name) { "family_name" }
      it { is_expected.to be_valid }
    end

    context "with an invalid DOB" do
      subject(:dob_error_message) { form.errors[:date_of_birth] }

      before { form.valid? }

      context "when DOB less than 18 years ago" do
        let(:date_of_birth) { 17.years.ago }

        it { is_expected.to eq(["You must be 18 or over to use this service"]) }
      end

      context "when DOB more than 100 years ago" do
        let(:date_of_birth) { 101.years.ago }

        it do
          is_expected.to eq(
            ["Your date of birth cannot be that far in the past"],
          )
        end
      end

      context "when DOB has a 2 digit year" do
        let(:date_of_birth) { "10/04/80" }

        it do
          is_expected.to eq(
            ["Enter your date of birth in the format 27 3 1980"],
          )
        end
      end

      context "when DOB is an invalid date" do
        let(:date_of_birth) { "31/13/1980" }

        it do
          is_expected.to eq(
            ["Enter your date of birth in the format 27 3 1980"],
          )
        end
      end
    end
  end

  describe "#save" do
    let(:form) do
      described_class.new(
        application_form:,
        given_names: "Given",
        family_name: "Family",
        date_of_birth: Date.new(2000, 1, 1),
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
