# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::RequestableReviewForm, type: :model do
  let(:requestable) { create(:reference_request, :received) }
  let(:user) { create(:staff) }
  let(:passed) { nil }
  let(:note) { "" }

  subject(:form) { described_class.new(requestable:, user:, passed:, note:) }

  describe "validations" do
    it { is_expected.to allow_values(true, false).for(:passed) }

    context "when not passed" do
      let(:passed) { "false" }

      it { is_expected.to validate_presence_of(:note) }
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    context "when passed is true" do
      let(:passed) { true }

      it "updates review passed field" do
        expect { save }.to change(requestable, :review_passed).from(nil).to(
          true,
        )
      end

      it "sets reviewed at" do
        freeze_time do
          expect { save }.to change(requestable, :reviewed_at).from(nil).to(
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
      let(:note) { "Note." }

      it "updates review passed field" do
        expect { save }.to change(requestable, :review_passed).from(nil).to(
          false,
        )
      end

      it "updates review note field" do
        expect { save }.to change(requestable, :review_note).from("").to(
          "Note.",
        )
      end

      it "sets reviewed at" do
        freeze_time do
          expect { save }.to change(requestable, :reviewed_at).from(nil).to(
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
