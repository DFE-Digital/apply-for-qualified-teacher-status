# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::RequestableLocationForm, type: :model do
  let(:requestable) { create(:professional_standing_request) }
  let(:user) { create(:staff) }

  let(:received) { "" }
  let(:location_note) { "" }

  subject(:form) do
    described_class.new(requestable:, user:, received:, location_note:)
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:requestable) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to allow_values(true, false).for(:received) }
  end

  describe "#save" do
    subject(:save) { form.save }

    context "when not received" do
      let(:received) { "" }
      let(:location_note) { "" }

      it { is_expected.to be true }

      it "doesn't change the state" do
        expect { save }.to_not change(requestable, :state)
      end

      it "doesn't record a timeline event" do
        expect { save }.to_not have_recorded_timeline_event(
          :requestable_received,
        )
      end

      context "when already received" do
        let(:requestable) { create(:professional_standing_request, :received) }

        it { is_expected.to be true }

        it "changes the state" do
          expect { save }.to change(requestable, :state).to("requested")
        end

        it "changes the note" do
          expect { save }.to change(requestable, :location_note).to("")
        end
      end
    end

    context "when received" do
      let(:received) { "true" }
      let(:location_note) { "Note." }

      it { is_expected.to be true }

      it "changes the state" do
        expect { save }.to change(requestable, :state).to("received")
      end

      it "changes the note" do
        expect { save }.to change(requestable, :location_note).to("Note.")
      end

      it "records a timeline event" do
        expect { save }.to have_recorded_timeline_event(
          :requestable_received,
          creator: user,
          requestable:,
        )
      end
    end
  end
end
