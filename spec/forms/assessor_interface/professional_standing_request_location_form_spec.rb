# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ProfessionalStandingRequestLocationForm,
               type: :model do
  let(:requestable) { create(:professional_standing_request) }
  let(:user) { create(:staff) }

  let(:received) { "" }
  let(:ready_for_review) { "" }
  let(:location_note) { "" }

  subject(:form) do
    described_class.new(
      requestable:,
      user:,
      received:,
      ready_for_review:,
      location_note:,
    )
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:requestable) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to allow_values(true, false).for(:received) }
    it { is_expected.to allow_values(true, false).for(:ready_for_review) }

    context "when not received" do
      let(:received) { "false" }

      it { is_expected.to_not allow_values(nil).for(:ready_for_review) }
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    context "when received" do
      let(:received) { "true" }
      let(:location_note) { "Note." }

      it { is_expected.to be true }

      it "sets the received at date" do
        expect { save }.to change(requestable, :received_at).from(nil)
      end

      it "sets the location note" do
        expect { save }.to change(requestable, :location_note).to("Note.")
      end

      it "records a received timeline event" do
        expect { save }.to have_recorded_timeline_event(
          :requestable_received,
          creator: user,
          requestable:,
        )
      end
    end

    context "when not received and ready for review" do
      let(:received) { "false" }
      let(:ready_for_review) { "true" }

      it { is_expected.to be true }

      it "sets ready for review" do
        expect { save }.to change(requestable, :ready_for_review).to(true)
      end
    end

    context "when not received and not ready for review" do
      let(:received) { "false" }
      let(:ready_for_review) { "false" }

      it { is_expected.to be true }

      it "doesn't set ready for review" do
        expect { save }.to_not change(requestable, :ready_for_review)
      end
    end
  end
end
