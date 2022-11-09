require "rails_helper"

RSpec.describe TeacherInterface::QualificationForm, type: :model do
  let(:qualification) { build(:qualification) }

  subject(:form) do
    described_class.new(
      qualification:,
      title:,
      institution_name:,
      institution_country_location:,
      start_date:,
      complete_date:,
      certificate_date:,
    )
  end

  describe "validations" do
    let(:title) { "" }
    let(:institution_name) { "" }
    let(:institution_country_location) { "" }
    let(:start_date) { "" }
    let(:complete_date) { "" }
    let(:certificate_date) { "" }

    it { is_expected.to validate_presence_of(:qualification) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:institution_name) }
    it { is_expected.to validate_presence_of(:institution_country_location) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:complete_date) }
    it { is_expected.to validate_presence_of(:certificate_date) }

    context "with invalid dates" do
      let(:start_date) { { 1 => 2020, 2 => 1, 3 => 1 } }
      let(:complete_date) { { 1 => 2019, 2 => 1, 3 => 1 } }

      it { is_expected.to_not be_valid }
    end

    context "with invalid dates" do
      let(:complete_date) { { 1 => 2020, 2 => 1, 3 => 1 } }
      let(:certificate_date) { { 1 => 2019, 2 => 1, 3 => 1 } }

      it { is_expected.to_not be_valid }
    end
  end

  context "with a country code" do
    subject(:institution_country_location) do
      described_class.new(
        institution_country_code: "FR",
      ).institution_country_location
    end

    it { is_expected.to eq("country:FR") }
  end

  describe "#save" do
    let(:title) { "Title" }
    let(:institution_name) { "Institution name" }
    let(:institution_country_location) { "country:FR" }
    let(:start_date) { { 1 => 2020, 2 => 1, 3 => 1 } }
    let(:complete_date) { { 1 => 2022, 2 => 1, 3 => 1 } }
    let(:certificate_date) { { 1 => 2022, 2 => 6, 3 => 1 } }

    subject(:save) { form.save(validate: true) }

    before { expect(save).to be true }

    it "saves the qualification" do
      expect(qualification.title).to eq("Title")
      expect(qualification.institution_name).to eq("Institution name")
      expect(qualification.institution_country_code).to eq("FR")
      expect(qualification.start_date).to eq(Date.new(2020, 1, 1))
      expect(qualification.complete_date).to eq(Date.new(2022, 1, 1))
      expect(qualification.certificate_date).to eq(Date.new(2022, 6, 1))
    end
  end
end
