require "rails_helper"

RSpec.describe TeacherInterface::AlternativeNameForm, type: :model do
  let(:application_form) { build(:application_form) }

  describe "validations" do
    subject(:form) do
      described_class.new(
        application_form:,
        has_alternative_name:,
        alternative_given_names:,
        alternative_family_name:,
      )
    end
    let(:has_alternative_name) { nil }
    let(:alternative_family_name) { nil }
    let(:alternative_given_names) { nil }

    it { is_expected.to validate_presence_of(:application_form) }

    context "when the fields are all blank" do
      let(:has_alternative_name) { "" }
      let(:alternative_given_names) { "" }
      let(:alternative_family_name) { "" }

      it { is_expected.to_not be_valid }
    end

    context "when the fields are blank and has_alternative_name is true" do
      let(:has_alternative_name) { true }
      let(:alternative_given_names) { "" }
      let(:alternative_family_name) { "" }

      it { is_expected.to_not be_valid }
    end

    context "when the fields are filled out and has_alternative_name is true" do
      let(:has_alternative_name) { true }
      let(:alternative_given_names) { "given_name" }
      let(:alternative_family_name) { "family_name" }

      it { is_expected.to be_valid }
    end

    context "when the fields are blank and has_alternative_name is false" do
      let(:has_alternative_name) { false }
      let(:alternative_given_names) { "" }
      let(:alternative_family_name) { "" }

      it { is_expected.to be_valid }
    end

    context "when the fields are filled out and has_alternative_name is false" do
      let(:has_alternative_name) { false }
      let(:alternative_given_names) { "given_name" }
      let(:alternative_family_name) { "family_name" }

      it { is_expected.to be_valid }
    end

    context "when only one field is filled out and has_alternative_name is false" do
      let(:has_alternative_name) { false }
      let(:alternative_given_names) { "" }
      let(:alternative_family_name) { "family_name" }

      it { is_expected.to be_valid }
    end

    context "when only one field is filled out and has_alternative_name is true" do
      let(:has_alternative_name) { true }
      let(:alternative_given_names) { "given_name" }
      let(:alternative_family_name) { "" }

      it { is_expected.to_not be_valid }
    end
  end

  describe "#save" do
    let(:form) do
      described_class.new(
        application_form:,
        has_alternative_name: "true",
        alternative_given_names: "Given",
        alternative_family_name: "Family",
      )
    end

    before { form.save }

    it "saves the application form" do
      expect(application_form.has_alternative_name).to eq(true)
      expect(application_form.alternative_given_names).to eq("Given")
      expect(application_form.alternative_family_name).to eq("Family")
    end
  end
end
