# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::RequestableVerifyPassedForm, type: :model do
  let(:requestable) do
    create(:reference_request, :requested, :receivable, verify_note: "Old note")
  end
  let(:user) { create(:staff) }
  let(:passed) { nil }
  let(:received) { nil }

  subject(:form) do
    described_class.new(requestable:, user:, passed:, received:)
  end

  describe "validations" do
    it { is_expected.to allow_values(true, false).for(:passed) }
    it { is_expected.to allow_values(nil, true, false).for(:received) }
  end

  describe "#save" do
    subject(:save) { form.save }

    context "when passed and received is true" do
      let(:passed) { true }
      let(:received) { nil }

      it "sets received_at" do
        freeze_time do
          expect { save }.to change(requestable, :received_at).from(nil).to(
            Time.zone.now,
          )
        end
      end

      it "sets verify_passed" do
        expect { save }.to change(requestable, :verify_passed).from(nil).to(
          true,
        )
      end

      it "sets verify_note" do
        expect { save }.to change(requestable, :verify_note).to("")
      end

      it "sets verified_at" do
        freeze_time do
          expect { save }.to change(requestable, :verified_at).from(nil).to(
            Time.zone.now,
          )
        end
      end

      it "updates induction required" do
        expect(UpdateAssessmentInductionRequired).to receive(:call)
        save # rubocop:disable Rails/SaveBang
      end
    end

    context "when passed is false" do
      let(:passed) { false }
      let(:received) { false }

      it "doesn't set received_at" do
        expect { save }.to_not change(requestable, :received_at)
      end

      it "doesn't set verify_passed" do
        expect { save }.to_not change(requestable, :verify_passed)
      end

      it "doesn't set verify_note" do
        expect { save }.to_not change(requestable, :verify_note)
      end

      it "doesn't set verified_at" do
        expect { save }.to_not change(requestable, :verified_at)
      end

      it "doesn't update induction required" do
        expect(UpdateAssessmentInductionRequired).to_not receive(:call)
        save # rubocop:disable Rails/SaveBang
      end
    end
  end
end
