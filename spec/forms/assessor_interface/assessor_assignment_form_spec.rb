require "rails_helper"

RSpec.describe AssessorInterface::AssessorAssignmentForm, type: :model do
  let(:application_form) do
    create(:application_form, :with_personal_information, :submitted)
  end
  let(:assessor_id) { create(:staff, :confirmed).id }
  let(:assigning_user_id) { create(:staff, :confirmed).id }

  subject do
    described_class.new(application_form:, assessor_id:, assigning_user_id:)
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to validate_presence_of(:assessor_id) }
    it { is_expected.to validate_presence_of(:assigning_user_id) }
  end

  describe "#save" do
    it "updates the application form" do
      subject.save!
      application_form.reload
      expect(application_form.assessor_id).to eq(assessor_id)
    end

    it "creates a timeline event" do
      expect { subject.save! }.to change { TimelineEvent.count }.by(1)
      created_event = TimelineEvent.last

      expect(created_event.creator_id).to eq(assigning_user_id)
      expect(created_event).to be_assessor_assigned
    end
  end
end
