require "rails_helper"

RSpec.describe AssessorInterface::ReviewerAssignmentForm, type: :model do
  let!(:application_form) do
    create(:application_form, :with_personal_information, :submitted)
  end
  let(:staff) { create(:staff, :confirmed) }
  let(:reviewer_id) { create(:staff, :confirmed).id }

  subject { described_class.new(application_form:, staff:, reviewer_id:) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to validate_presence_of(:staff) }
    it { is_expected.to validate_presence_of(:reviewer_id) }
  end

  describe "#save" do
    it "updates the application form" do
      subject.save!
      application_form.reload
      expect(application_form.reviewer_id).to eq(reviewer_id)
    end

    it "creates a timeline event" do
      expect { subject.save! }.to change { TimelineEvent.count }.by(1)
      created_event = TimelineEvent.last

      expect(created_event.creator).to eq(staff)
      expect(created_event).to be_reviewer_assigned
    end
  end
end
