# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::QualificationRequestForm, type: :model do
  let(:requestable) { create(:qualification_request) }
  let(:user) { create(:staff) }

  let(:received) { "" }
  let(:passed) { "" }
  let(:note) { "" }
  let(:failed) { "" }

  subject(:form) do
    described_class.new(requestable:, user:, received:, passed:, note:, failed:)
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:requestable) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to allow_values(true, false).for(:received) }
    it { is_expected.to allow_values(true, false).for(:passed) }
    it { is_expected.to allow_values(true, false).for(:failed) }

    context "when received" do
      let(:received) { "true" }

      it { is_expected.to_not allow_values(nil).for(:passed) }

      context "and not passed" do
        let(:passed) { "false" }

        it { is_expected.to validate_presence_of(:note) }
      end
    end

    context "when not received" do
      let(:received) { "false" }

      it { is_expected.to_not allow_values(nil).for(:failed) }
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    context "when received and passed" do
      let(:received) { "true" }
      let(:passed) { "true" }

      it { is_expected.to be true }

      it "sets the received at date" do
        expect { save }.to change(requestable, :received_at).from(nil)
      end

      it "sets review passed" do
        expect { save }.to change(requestable, :review_passed).to(true)
      end

      it "records a received timeline event" do
        expect { save }.to have_recorded_timeline_event(
          :requestable_received,
          creator: user,
          requestable:,
        )
      end

      it "records an reviewed timeline event" do
        expect { save }.to have_recorded_timeline_event(
          :requestable_reviewed,
          creator: user,
          requestable:,
        )
      end
    end

    context "when received and not passed" do
      let(:received) { "true" }
      let(:passed) { "false" }
      let(:note) { "Note." }

      it { is_expected.to be true }

      it "sets the received at date" do
        expect { save }.to change(requestable, :received_at).from(nil)
      end

      it "sets review passed" do
        expect { save }.to change(requestable, :review_passed).to(false)
      end

      it "sets review note" do
        expect { save }.to change(requestable, :review_note).to("Note.")
      end

      it "records a received timeline event" do
        expect { save }.to have_recorded_timeline_event(
          :requestable_received,
          creator: user,
          requestable:,
        )
      end

      it "records an reviewed timeline event" do
        expect { save }.to have_recorded_timeline_event(
          :requestable_reviewed,
          creator: user,
          requestable:,
        )
      end
    end

    context "when not received and failed" do
      let(:received) { "false" }
      let(:failed) { "true" }

      it { is_expected.to be true }

      it "sets review passed" do
        expect { save }.to change(requestable, :review_passed).to(false)
      end

      it "records an assessed timeline event" do
        expect { save }.to have_recorded_timeline_event(
          :requestable_reviewed,
          creator: user,
          requestable:,
        )
      end
    end

    context "when not received and not failed" do
      let(:received) { "false" }
      let(:failed) { "false" }

      it { is_expected.to be true }

      it "doesn't set review passed" do
        expect { save }.to_not change(requestable, :review_passed)
      end

      it "doesn't record a reviewed timeline event" do
        expect { save }.to_not have_recorded_timeline_event(
          :requestable_reviewed,
        )
      end
    end
  end
end
