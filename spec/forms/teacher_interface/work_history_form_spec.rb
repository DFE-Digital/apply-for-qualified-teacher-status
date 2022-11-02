require "rails_helper"

RSpec.describe TeacherInterface::WorkHistoryForm, type: :model do
  let(:work_history) { build(:work_history) }

  subject(:form) do
    described_class.new(
      work_history:,
      job:,
      school_name:,
      city:,
      country_location:,
      contact_name:,
      contact_email:,
      start_date:,
      still_employed:,
      end_date:,
    )
  end

  describe "validations" do
    let(:job) { "" }
    let(:school_name) { "" }
    let(:city) { "" }
    let(:country_location) { "" }
    let(:contact_name) { "" }
    let(:contact_email) { "" }
    let(:start_date) { "" }
    let(:still_employed) { "" }
    let(:end_date) { "" }

    it { is_expected.to validate_presence_of(:job) }
    it { is_expected.to validate_presence_of(:school_name) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:country_location) }
    it { is_expected.to validate_presence_of(:contact_name) }
    it { is_expected.to validate_presence_of(:contact_email) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to allow_values(true, false).for(:still_employed) }

    describe "start_date" do
      it "is required" do
        form.valid?
        expect(form.errors[:start_date]).to eq(
          ["Enter the start date in the format 27 3 1980"],
        )
      end

      it "must be valid" do
        form.start_date = { 1 => 2022, 2 => 13, 3 => 1 }
        form.valid?
        expect(form.errors[:start_date]).to eq(
          ["Enter the start date in the format 27 3 1980"],
        )
      end

      it "must be in the past" do
        future = 1.month.from_now
        form.start_date = { 1 => future.year, 2 => future.month, 3 => 1 }
        form.valid?
        expect(form.errors[:start_date]).to eq(
          ["Start date must be in the past"],
        )
      end
    end

    describe "end_date" do
      context "when still employed" do
        let(:still_employed) { "true" }

        it "isn't required" do
          form.valid?
          expect(form.errors[:end_date]).to eq([])
        end
      end

      context "when not still employed" do
        let(:still_employed) { "false" }

        it "is required" do
          form.valid?
          expect(form.errors[:end_date]).to eq(
            ["Enter the end date in the format 27 3 1980"],
          )
        end

        it "must be valid" do
          form.end_date = { 1 => 2022, 2 => 13, 3 => 1 }
          form.valid?
          expect(form.errors[:end_date]).to eq(
            ["Enter the end date in the format 27 3 1980"],
          )
        end

        it "must be after start_date" do
          form.end_date = { 1 => 2022, 2 => 10, 3 => 1 }
          form.start_date = { 1 => 2022, 2 => 11, 3 => 1 }
          form.valid?
          expect(form.errors[:end_date]).to eq(
            ["End date must be after start date"],
          )
        end
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
    let(:job) { "Job" }
    let(:school_name) { "School" }
    let(:city) { "City" }
    let(:country_location) { "country:FR" }
    let(:contact_name) { "First Last" }
    let(:contact_email) { "school@example.com" }
    let(:start_date) { { 1 => 2020, 2 => 10, 3 => 1 } }
    let(:still_employed) { "true" }
    let(:end_date) { "" }

    subject(:save) { form.save(validate: true) }

    before { expect(save).to be true }

    it "saves the work history" do
      expect(work_history.job).to eq("Job")
      expect(work_history.school_name).to eq("School")
      expect(work_history.city).to eq("City")
      expect(work_history.country_code).to eq("FR")
      expect(work_history.contact_name).to eq("First Last")
      expect(work_history.contact_email).to eq("school@example.com")
      expect(work_history.start_date).to eq(Date.new(2020, 10, 1))
      expect(work_history.still_employed).to be true
      expect(work_history.end_date).to be_nil
    end
  end
end
