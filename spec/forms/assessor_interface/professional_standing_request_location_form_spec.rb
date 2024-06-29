# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ProfessionalStandingRequestLocationForm,
               type: :model do
  subject(:form) do
    described_class.new(requestable:, user:, received:, location_note:)
  end

  let(:requestable) { create(:professional_standing_request) }
  let(:user) { create(:staff) }

  let(:received) { "" }
  let(:location_note) { "" }

  describe "validations" do
    it { is_expected.to validate_presence_of(:requestable) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to allow_values(true, false).for(:received) }
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

    context "when not received" do
      let(:received) { "false" }

      it { is_expected.to be true }
    end
  end
end
