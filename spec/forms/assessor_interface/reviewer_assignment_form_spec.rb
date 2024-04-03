require "rails_helper"

RSpec.describe AssessorInterface::ReviewerAssignmentForm, type: :model do
  let!(:application_form) do
    create(:application_form, :with_personal_information, :submitted)
  end
  let(:staff) { create(:staff) }
  let(:reviewer_id) { create(:staff).id }

  subject(:form) do
    described_class.new(application_form:, staff:, reviewer_id:)
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to validate_presence_of(:staff) }
    it { is_expected.to_not validate_presence_of(:reviewer_id) }

    context "if reviewer matches assessor" do
      before { application_form.update!(assessor_id: reviewer_id) }

      it { is_expected.to be_invalid }
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    it "updates the application form" do
      expect { save }.to change(application_form, :reviewer_id).to(reviewer_id)
    end

    it "records a timeline event" do
      expect { save }.to have_recorded_timeline_event(
        :reviewer_assigned,
        creator: staff,
      )
    end
  end
end
