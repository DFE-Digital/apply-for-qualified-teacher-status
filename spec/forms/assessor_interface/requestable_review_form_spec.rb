# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::RequestableReviewForm, type: :model do
  let(:requestable) { create(:reference_request, :received) }
  let(:user) { create(:staff) }
  let(:reviewed) { nil }
  let(:passed) { nil }
  let(:failure_assessor_note) { "" }

  subject(:form) do
    described_class.new(
      requestable:,
      user:,
      reviewed:,
      passed:,
      failure_assessor_note:,
    )
  end

  describe "validations" do
    it { is_expected.to allow_values(true, false).for(:reviewed) }
    it { is_expected.to allow_values(true, false).for(:passed) }

    context "when locatable" do
      let(:requestable) { create(:qualification_request) }

      it { is_expected.to_not allow_values(nil).for(:reviewed) }

      context "when reviewed" do
        let(:reviewed) { "true" }

        it { is_expected.to_not allow_values(nil).for(:passed) }
      end
    end

    context "when not locatable" do
      it { is_expected.to_not allow_values(nil).for(:passed) }
    end

    context "when not passed" do
      let(:passed) { "false" }

      it { is_expected.to validate_presence_of(:failure_assessor_note) }
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    context "when passed is true" do
      let(:passed) { true }

      it "updates passed field" do
        expect { save }.to change(requestable, :passed).from(nil).to(true)
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
      let(:failure_assessor_note) { "Note." }

      it "updates passed field" do
        expect { save }.to change(requestable, :passed).from(nil).to(false)
      end

      it "updates failure_assessor_note field" do
        expect { save }.to change(requestable, :failure_assessor_note).from(
          "",
        ).to("Note.")
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

    context "when not reviewed and passed" do
      let(:reviewed) { "false" }
      let(:passed) { "true" }

      it "doesn't set passed" do
        expect { save }.to_not change(requestable, :passed).from(nil)
      end

      it "doesn't set reviewed at" do
        freeze_time do
          expect { save }.to_not change(requestable, :reviewed_at).from(nil)
        end
      end
    end
  end
end
