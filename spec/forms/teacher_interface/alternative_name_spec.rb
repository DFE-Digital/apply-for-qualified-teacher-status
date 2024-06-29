require "rails_helper"

RSpec.describe TeacherInterface::AlternativeNameForm, type: :model do
  subject(:form) do
    described_class.new(
      application_form:,
      has_alternative_name:,
      alternative_given_names:,
      alternative_family_name:,
    )
  end

  let(:application_form) { build(:application_form) }

  describe "validations" do
    let(:has_alternative_name) { "" }
    let(:alternative_given_names) { "" }
    let(:alternative_family_name) { "" }

    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to allow_values(true, false).for(:has_alternative_name) }

    context "when has alternative name is true" do
      let(:has_alternative_name) { "true" }

      it { is_expected.to validate_presence_of(:alternative_given_names) }
      it { is_expected.to validate_presence_of(:alternative_family_name) }
    end

    context "when has alternative name is false" do
      let(:has_alternative_name) { "false" }

      it { is_expected.not_to validate_presence_of(:alternative_given_names) }
      it { is_expected.not_to validate_presence_of(:alternative_family_name) }
    end
  end

  describe "#save" do
    let(:has_alternative_name) { "true" }
    let(:alternative_given_names) { "Given" }
    let(:alternative_family_name) { "Family" }

    before { form.save(validate: true) }

    it "saves the application form" do
      expect(application_form.has_alternative_name).to be(true)
      expect(application_form.alternative_given_names).to eq("Given")
      expect(application_form.alternative_family_name).to eq("Family")
    end
  end
end
