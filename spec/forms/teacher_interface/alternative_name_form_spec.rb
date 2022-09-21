require "rails_helper"

RSpec.describe TeacherInterface::AlternativeNameForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:application_form) }
  end

  let(:application_form) { build(:application_form) }

  describe "#valid?" do
    subject(:valid?) { form.valid? }

    let(:form) do
      described_class.new(
        application_form:,
        has_alternative_name:,
        alternative_given_names:,
        alternative_family_name:,
      )
    end
    let(:has_alternative_name) { "" }
    let(:alternative_given_names) { "" }
    let(:alternative_family_name) { "" }

    it { is_expected.to be true }
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
