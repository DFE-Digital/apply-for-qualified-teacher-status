require "rails_helper"

RSpec.describe AssessorInterface::AssessorAssignmentForm, type: :model do
  let!(:application_form) do
    create(:application_form, :with_personal_information, :submitted)
  end
  let(:staff) { create(:staff, :confirmed) }
  let(:assessor_id) { create(:staff, :confirmed).id }

  subject(:form) do
    described_class.new(application_form:, staff:, assessor_id:)
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to validate_presence_of(:staff) }
    it { is_expected.to_not validate_presence_of(:assessor_id) }
  end

  describe "#save" do
    subject(:save) { form.save }

    it "updates the application form" do
      expect { save }.to change(application_form, :assessor_id).to(assessor_id)
    end

    it "creates a timeline event" do
      expect { save }.to change { TimelineEvent.count }.by(1)

      created_event = TimelineEvent.last
      expect(created_event.creator).to eq(staff)
      expect(created_event).to be_assessor_assigned
    end
  end
end
