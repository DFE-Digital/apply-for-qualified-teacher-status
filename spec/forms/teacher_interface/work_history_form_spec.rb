require "rails_helper"

RSpec.describe TeacherInterface::WorkHistoryForm, type: :model do
  let(:work_history) { build(:work_history) }

  subject(:form) do
    described_class.new(
      work_history:,
      job:,
      school_name:,
      city:,
      country_code:,
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
    let(:country_code) { "" }
    let(:contact_name) { "" }
    let(:contact_email) { "" }
    let(:start_date) { "" }
    let(:still_employed) { "" }
    let(:end_date) { "" }

    it { is_expected.to validate_presence_of(:job) }
    it { is_expected.to validate_presence_of(:school_name) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:country_code) }
    it { is_expected.to validate_presence_of(:contact_name) }
    it { is_expected.to validate_presence_of(:contact_email) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to allow_values(true, false).for(:still_employed) }

    context "when still employed" do
      let(:still_employed) { "true" }

      it { is_expected.to_not validate_presence_of(:end_date) }
    end

    context "when not still employed" do
      let(:still_employed) { "false" }

      it { is_expected.to validate_presence_of(:end_date) }
    end
  end

  describe "#save" do
    let(:job) { "Job" }
    let(:school_name) { "School" }
    let(:city) { "City" }
    let(:country_code) { "country:FR" }
    let(:contact_name) { "First Last" }
    let(:contact_email) { "school@example.com" }
    let(:start_date) { "2020-01-01" }
    let(:still_employed) { "true" }
    let(:end_date) { "" }

    before { form.save(validate: true) }

    it "saves the work history" do
      expect(work_history.job).to eq("Job")
      expect(work_history.school_name).to eq("School")
      expect(work_history.city).to eq("City")
      expect(work_history.country_code).to eq("FR")
      expect(work_history.contact_name).to eq("First Last")
      expect(work_history.contact_email).to eq("school@example.com")
      expect(work_history.start_date).to eq(Date.new(2020, 1, 1))
      expect(work_history.still_employed).to be true
      expect(work_history.end_date).to be_nil
    end
  end
end
