# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ProfessionalStandingRequestForm,
               type: :model do
  let(:professional_standing_request) { create(:professional_standing_request) }
  let(:user) { create(:staff) }

  let(:received) { "" }
  let(:location_note) { "" }

  subject(:form) do
    described_class.new(
      professional_standing_request:,
      user:,
      received:,
      location_note:,
    )
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:professional_standing_request) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to allow_values(true, false).for(:received) }

    context "when received" do
      let(:received) { "true" }

      it { is_expected.to validate_presence_of(:location_note) }
    end

    context "when not received" do
      let(:received) { "" }

      it { is_expected.to_not validate_presence_of(:location_note) }
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    context "when not received" do
      let(:received) { "" }

      it { is_expected.to be true }

      it "doesn't change the state" do
        expect { save }.to_not change(professional_standing_request, :state)
      end

      it "doesn't record a timeline event" do
        expect { save }.to_not have_recorded_timeline_event(
          :requestable_received,
        )
      end
    end

    context "when received" do
      let(:received) { "true" }
      let(:location_note) { "Note." }

      it { is_expected.to be true }

      it "changes the state" do
        expect { save }.to change(professional_standing_request, :state).to(
          "received",
        )
      end

      it "changes the note" do
        expect { save }.to change(
          professional_standing_request,
          :location_note,
        ).to("Note.")
      end

      it "records a timeline event" do
        expect { save }.to have_recorded_timeline_event(
          :requestable_received,
          creator: user,
          requestable: professional_standing_request,
        )
      end
    end
  end
end
