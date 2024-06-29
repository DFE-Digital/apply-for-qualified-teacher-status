# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::AssessorAssignmentForm, type: :model do
  subject(:form) do
    described_class.new(application_form:, staff:, assessor_id:)
  end

  let!(:application_form) do
    create(:application_form, :with_personal_information, :submitted)
  end
  let(:staff) { create(:staff) }
  let(:assessor_id) { create(:staff).id }

  describe "validations" do
    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to validate_presence_of(:staff) }
    it { is_expected.not_to validate_presence_of(:assessor_id) }

    context "if assessor matches reviewer" do
      before { application_form.update!(reviewer_id: assessor_id) }

      it { is_expected.to be_invalid }
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    it "updates the application form" do
      expect { save }.to change(application_form, :assessor_id).to(assessor_id)
    end

    it "records a timeline event" do
      expect { save }.to have_recorded_timeline_event(
        :assessor_assigned,
        creator: staff,
      )
    end
  end
end
