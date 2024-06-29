# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::RequestableVerifyFailedForm, type: :model do
  subject(:form) { described_class.new(requestable:, user:, note:) }

  let(:requestable) { create(:received_reference_request) }
  let(:user) { create(:staff) }
  let(:note) { "" }

  describe "validations" do
    it { is_expected.to validate_presence_of(:note) }
  end

  describe "#save" do
    subject(:save) { form.save }

    context "when passed is false" do
      let(:note) { "Note." }

      it "sets verify_passed" do
        expect { save }.to change(requestable, :verify_passed).from(nil).to(
          false,
        )
      end

      it "sets verify_note" do
        expect { save }.to change(requestable, :verify_note).from("").to(
          "Note.",
        )
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
  end
end
