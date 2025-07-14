# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::PrioritisationWorkHistoryCheckForm,
               type: :model do
  subject(:form) do
    described_class.new(prioritisation_work_history_check:, passed:)
  end

  let(:assessment) { create(:assessment) }

  let(:prioritisation_work_history_check) do
    create(:prioritisation_work_history_check, assessment:)
  end

  let(:passed) { "" }

  describe "validations" do
    it { is_expected.to allow_values(true, false).for(:passed) }
  end

  describe "#save" do
    subject(:save) { form.save }

    context "when passed" do
      let(:passed) { "true" }

      it { is_expected.to be true }

      it "sets the passed to true" do
        expect { save }.to change(
          prioritisation_work_history_check,
          :passed,
        ).from(nil).to(true)
      end

      it "sets the assessment started_at" do
        expect { save }.to change(assessment, :started_at)

        expect(assessment.started_at).not_to be_nil
      end
    end

    context "when not passed" do
      let(:passed) { "false" }

      it { is_expected.to be true }

      it "sets the passed to true" do
        expect { save }.to change(
          prioritisation_work_history_check,
          :passed,
        ).from(nil).to(false)
      end

      it "sets the assessment started_at" do
        expect { save }.to change(assessment, :started_at)

        expect(assessment.started_at).not_to be_nil
      end
    end
  end
end
