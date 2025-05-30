# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::WorkHistorySchoolForm, type: :model do
  subject(:form) do
    described_class.new(
      work_history:,
      meets_all_requirements:,
      school_name:,
      address_line1:,
      address_line2:,
      city:,
      country_location:,
      postcode:,
      school_website:,
      job:,
      hours_per_week:,
      start_date:,
      start_date_is_estimate:,
      still_employed:,
      end_date:,
      end_date_is_estimate:,
    )
  end

  let(:application_form) { create(:application_form) }
  let(:work_history) { build(:work_history, application_form:) }

  describe "validations" do
    let(:meets_all_requirements) { "" }
    let(:school_name) { "" }
    let(:address_line1) { "" }
    let(:address_line2) { "" }
    let(:city) { "" }
    let(:country_location) { "" }
    let(:postcode) { "" }
    let(:school_website) { "" }
    let(:job) { "" }
    let(:hours_per_week) { "" }
    let(:start_date) { "" }
    let(:start_date_is_estimate) { "" }
    let(:still_employed) { "" }
    let(:end_date) { "" }
    let(:end_date_is_estimate) { "" }

    it { is_expected.to validate_presence_of(:meets_all_requirements) }
    it { is_expected.to validate_presence_of(:school_name) }
    it { is_expected.to validate_presence_of(:address_line1) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:country_location) }
    it { is_expected.to validate_presence_of(:job) }
    it { is_expected.to validate_presence_of(:hours_per_week) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to allow_values(true, false).for(:still_employed) }

    context "with an invalid start date" do
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

      context "with an invalid end date" do
        let(:end_date) { { 1 => 2022, 2 => 13, 3 => 1 } }

        it { is_expected.not_to be_valid }
      end

      context "with a start date after the end date" do
        let(:start_date) { { 1 => 2022, 2 => 11, 3 => 1 } }
        let(:end_date) { { 1 => 2022, 2 => 10, 3 => 1 } }

        it { is_expected.not_to be_valid }
      end
    end
  end

  context "with a country code" do
    subject(:country_location) do
      described_class.new(country_code: "FR").country_location
    end

    it { is_expected.to eq("country:FR") }
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    let(:meets_all_requirements) { "true" }
    let(:school_name) { "School" }
    let(:address_line1) { "Address Line 1" }
    let(:address_line2) { "Address Line 2" }
    let(:city) { "City" }
    let(:country_location) { "country:FR" }
    let(:postcode) { "12345" }
    let(:school_website) { "www.website.com" }
    let(:job) { "Job" }
    let(:hours_per_week) { "30" }
    let(:start_date) { { 1 => 2020, 2 => 10, 3 => 1 } }
    let(:start_date_is_estimate) { "" }
    let(:still_employed) { "false" }
    let(:end_date) { { 1 => 2021, 2 => 10, 3 => 1 } }
    let(:end_date_is_estimate) { "" }

    before { expect(save).to be true }

    it "saves the work history" do
      expect(work_history.school_name).to eq("School")
      expect(work_history.city).to eq("City")
      expect(work_history.country_code).to eq("FR")
      expect(work_history.postcode).to eq("12345")
      expect(work_history.job).to eq("Job")
      expect(work_history.hours_per_week).to eq(30)
      expect(work_history.start_date).to eq(Date.new(2020, 10, 1))
      expect(work_history.start_date_is_estimate).to be false
      expect(work_history.still_employed).to be false
      expect(work_history.end_date).to eq(Date.new(2021, 10, 1))
      expect(work_history.end_date_is_estimate).to be false
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

    context "when showing the duration banner" do
      let(:application_form) do
        create(
          :application_form,
          qualification_changed_work_history_duration: true,
        )
      end

      context "with enough work history for submission" do
        let(:end_date) { { 1 => 2021, 2 => 10, 3 => 1 } }

        it "clears the banner" do
          expect(
            application_form.qualification_changed_work_history_duration,
          ).to be false
        end
      end

      context "without enough work history for submission" do
        let(:end_date) { { 1 => 2020, 2 => 11, 3 => 1 } }

        it "doesn't clear the banner" do
          expect(
            application_form.qualification_changed_work_history_duration,
          ).to be true
        end
      end
    end
  end
end
