require "rails_helper"

RSpec.describe TeacherInterface::WorkHistoryContactForm, type: :model do
  let(:work_history) { build(:work_history) }

  subject(:form) do
    described_class.new(
      work_history:,
      contact_name:,
      contact_job:,
      contact_email:,
    )
  end

  describe "validations" do
    let(:contact_name) { "" }
    let(:contact_job) { "" }
    let(:contact_email) { "" }

    it { is_expected.to validate_presence_of(:contact_name) }
    it { is_expected.to validate_presence_of(:contact_job) }
    it { is_expected.to validate_presence_of(:contact_email) }
  end

  describe "#save" do
    let(:contact_name) { "First Last" }
    let(:contact_job) { "Job" }
    let(:contact_email) { "school@example.com" }

    subject(:save) { form.save(validate: true) }

    before { expect(save).to be true }

    it "saves the work history" do
      expect(work_history.contact_name).to eq("First Last")
      expect(work_history.contact_job).to eq("Job")
      expect(work_history.contact_email).to eq("school@example.com")
    end
  end
end
