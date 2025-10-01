# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ReactivateEligibilityDomainForm,
               type: :model do
  subject { described_class.new(eligibility_domain:, reactivated_by:, note:) }

  let(:eligibility_domain) do
    create(:eligibility_domain, archived_at: Time.current)
  end
  let(:reactivated_by) { create(:staff) }
  let(:note) { "A note." }

  describe "validations" do
    it { is_expected.to validate_presence_of(:reactivated_by) }
    it { is_expected.to validate_presence_of(:note) }
  end

  describe "#save" do
    subject(:save) do
      described_class.new(eligibility_domain:, reactivated_by:, note:).save
    end

    it "archives the eligibility domain record" do
      subject

      expect(eligibility_domain.archived_at).to be_nil
    end

    it "records a timeline event" do
      expect { subject }.to have_recorded_timeline_event(
        :eligibility_domain_reactivated,
        creator: reactivated_by,
        note_text: note,
      )
    end
  end
end
