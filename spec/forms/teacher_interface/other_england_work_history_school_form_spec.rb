# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::OtherEnglandWorkHistorySchoolForm,
               type: :model do
  subject(:form) do
    described_class.new(
      work_history:,
      school_name:,
      address_line1:,
      address_line2:,
      city:,
      country_location:,
      postcode:,
      school_website:,
      job:,
      start_date:,
      still_employed:,
      end_date:,
    )
  end

  let(:application_form) { create(:application_form) }
  let(:work_history) { build(:work_history, application_form:) }

  describe "validations" do
    let(:school_name) { "" }
    let(:address_line1) { "" }
    let(:address_line2) { "" }
    let(:city) { "" }
    let(:country_location) { "" }
    let(:postcode) { "" }
    let(:school_website) { "" }
    let(:job) { "" }
    let(:start_date) { "" }
    let(:still_employed) { "" }
    let(:end_date) { "" }

    it { is_expected.to validate_presence_of(:school_name) }
    it { is_expected.to validate_presence_of(:address_line1) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:country_location) }
    it { is_expected.to validate_presence_of(:job) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:postcode) }
    it { is_expected.to allow_values(true, false).for(:still_employed) }
    it { is_expected.to allow_values("country:GB-ENG").for(:country_location) }

    context "with an invalid start date format" do
      let(:start_date) { { 1 => 2022, 2 => 13, 3 => 1 } }

      it { is_expected.not_to be_valid }
    end

    context "with a start date in the future" do
      let(:start_date) { { 1 => 1.year.from_now.year, 2 => 1, 3 => 1 } }

      it { is_expected.not_to be_valid }
    end

    context "when still employed" do
      let(:still_employed) { "true" }

      it { is_expected.not_to validate_presence_of(:end_date) }
    end

    context "when not still employed" do
      let(:still_employed) { "false" }

      it { is_expected.to validate_presence_of(:end_date) }

      context "with an invalid end date format" do
        let(:end_date) { { 1 => 2022, 2 => 13, 3 => 1 } }

        it { is_expected.not_to be_valid }
      end

      context "with a start date after the end date" do
        let(:start_date) { { 1 => 2022, 2 => 11, 3 => 1 } }
        let(:end_date) { { 1 => 2022, 2 => 10, 3 => 1 } }

        it { is_expected.not_to be_valid }
      end

      context "with end date more than a year ago" do
        let(:end_date) { { 1 => 2023, 2 => 1, 3 => 1 } }

        it { is_expected.not_to be_valid }
      end
    end
  end

  context "with a country code" do
    subject(:country_location) do
      described_class.new(country_code: "GB-ENG").country_location
    end

    it { is_expected.to eq("country:GB-ENG") }
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    let(:meets_all_requirements) { "true" }
    let(:school_name) { "School" }
    let(:address_line1) { "Address Line 1" }
    let(:address_line2) { "Address Line 2" }
    let(:city) { "City" }
    let(:country_location) { "country:GB-ENG" }
    let(:postcode) { "12345" }
    let(:school_website) { "www.website.com" }
    let(:job) { "Job" }
    let(:start_date) { { 1 => 2020, 2 => 10, 3 => 1 } }
    let(:still_employed) { "false" }
    let(:end_date) do
      { 1 => Date.current.year, 2 => Date.current.month, 3 => 1 }
    end

    before { expect(save).to be true }

    it "saves the work history" do
      expect(work_history.school_name).to eq("School")
      expect(work_history.city).to eq("City")
      expect(work_history.country_code).to eq("GB-ENG")
      expect(work_history.postcode).to eq("12345")
      expect(work_history.job).to eq("Job")
      expect(work_history.start_date).to eq(Date.new(2020, 10, 1))
      expect(work_history.still_employed).to be false
      expect(work_history.end_date).to eq(Date.current.beginning_of_month)
      expect(work_history.is_other_england_educational_role).to be(true)
    end

    context "without validation, with invalid date values" do
      subject(:save) { form.save(validate: false) }

      let(:start_date) { { 1 => 2222, 2 => 22, 3 => 1 } }
      let(:end_date) { { 1 => 3333, 2 => 99, 3 => 1 } }

      it "applies valid date values" do
        expect(work_history.start_date).to eq(
          Date.new(Time.zone.now.year, 1, 1),
        )
        expect(work_history.end_date).to eq(Date.new(Time.zone.now.year, 1, 1))
      end
    end

    context "with an end date and still employed" do
      let(:still_employed) { "true" }
      let(:end_date) { { 1 => 2020, 2 => 1, 3 => 1 } }

      it "clears the end date" do
        expect(work_history.still_employed).to be true
        expect(work_history.end_date).to be_nil
      end
    end
  end
end
