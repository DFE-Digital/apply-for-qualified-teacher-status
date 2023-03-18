# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::QualificationRequestForm, type: :model do
  let(:requestable) { create(:qualification_request) }
  let(:user) { create(:staff) }

  let(:received) { "" }
  let(:passed) { "" }
  let(:failure_assessor_note) { "" }
  let(:failed) { "" }

  subject(:form) do
    described_class.new(
      requestable:,
      user:,
      received:,
      passed:,
      failure_assessor_note:,
      failed:,
    )
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

        it { is_expected.to validate_presence_of(:failure_assessor_note) }
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

      it "changes the state" do
        expect { save }.to change(requestable, :state).to("received")
      end

      it "sets passed" do
        expect { save }.to change(requestable, :passed).to(true)
      end

      it "records a received timeline event" do
        expect { save }.to have_recorded_timeline_event(
          :requestable_received,
          creator: user,
          requestable:,
        )
      end

      it "records an assessed timeline event" do
        expect { save }.to have_recorded_timeline_event(
          :requestable_assessed,
          creator: user,
          requestable:,
        )
      end
    end

    context "when received and not passed" do
      let(:received) { "true" }
      let(:passed) { "false" }
      let(:failure_assessor_note) { "Note." }

      it { is_expected.to be true }

      it "changes the state" do
        expect { save }.to change(requestable, :state).to("received")
      end

      it "sets passed" do
        expect { save }.to change(requestable, :passed).to(false)
      end

      it "sets passed" do
        expect { save }.to change(requestable, :failure_assessor_note).to(
          "Note.",
        )
      end

      it "records a received timeline event" do
        expect { save }.to have_recorded_timeline_event(
          :requestable_received,
          creator: user,
          requestable:,
        )
      end

      it "records an assessed timeline event" do
        expect { save }.to have_recorded_timeline_event(
          :requestable_assessed,
          creator: user,
          requestable:,
        )
      end
    end

    context "when not received and failed" do
      let(:received) { "false" }
      let(:failed) { "true" }

      it { is_expected.to be true }

      it "changes the state" do
        expect { save }.to change(requestable, :state).to("expired")
      end

      it "sets passed" do
        expect { save }.to change(requestable, :passed).to(false)
      end

      it "records an expired timeline event" do
        expect { save }.to have_recorded_timeline_event(
          :requestable_expired,
          creator: user,
          requestable:,
        )
      end

      it "records an assessed timeline event" do
        expect { save }.to have_recorded_timeline_event(
          :requestable_assessed,
          creator: user,
          requestable:,
        )
      end
    end

    context "when not received and not failed" do
      let(:received) { "false" }
      let(:failed) { "false" }

      it { is_expected.to be true }

      it "changes the state" do
        expect { save }.to change(requestable, :state).to("expired")
      end

      it "doesn't set passed" do
        expect { save }.to_not change(requestable, :passed)
      end

      it "records an expired timeline event" do
        expect { save }.to have_recorded_timeline_event(
          :requestable_expired,
          creator: user,
          requestable:,
        )
      end

      it "doesn't record an assessed timeline event" do
        expect { save }.to_not have_recorded_timeline_event(
          :requestable_assessed,
        )
      end
    end
  end
end
