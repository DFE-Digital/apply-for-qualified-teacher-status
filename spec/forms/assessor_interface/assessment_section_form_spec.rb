# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::AssessmentSectionForm, type: :model do
  let(:assessment_section) do
    create(
      :assessment_section,
      key: "personal_information",
      failure_reasons: [
        further_information_failure_reason,
        work_history_failure_reason,
        decline_failure_reason,
      ],
    )
  end
  let(:further_information_failure_reason) do
    (
      FailureReasons::FURTHER_INFORMATIONABLE -
        FailureReasons::WORK_HISTORY_FAILURE_REASONS
    ).sample.to_sym
  end
  let(:work_history_failure_reason) do
    FailureReasons::WORK_HISTORY_FAILURE_REASONS.sample.to_sym
  end
  let(:decline_failure_reason) { FailureReasons::DECLINABLE.sample.to_sym }
  let(:user) { create(:staff) }
  let(:attributes) { {} }

  subject(:form) do
    described_class.for_assessment_section(assessment_section).new(
      assessment_section:,
      user:,
      **attributes,
    )
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:assessment_section) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to allow_values(true, false).for(:passed) }

    context "when passed" do
      let(:attributes) { { passed: true } }

      it { is_expected.to be_valid }
    end

    context "when reasons are checked" do
      let(:attributes) do
        {
          passed: false,
          "#{further_information_failure_reason}_checked": true,
          "#{work_history_failure_reason}_checked": true,
          "#{decline_failure_reason}_checked": true,
        }
      end

      it do
        is_expected.to validate_presence_of(
          :"#{further_information_failure_reason}_notes",
        )
      end
      it do
        is_expected.to validate_presence_of(
          :"#{work_history_failure_reason}_notes",
        )
      end
      it do
        is_expected.not_to validate_presence_of(
          :"#{decline_failure_reason}_notes",
        )
      end
    end

    context "when reasons are checked and notes are provided" do
      let(:attributes) do
        {
          passed: false,
          "#{further_information_failure_reason}_checked": true,
          "#{further_information_failure_reason}_notes": "Notes.",
          "#{work_history_failure_reason}_checked": true,
          "#{work_history_failure_reason}_notes": "Notes.",
          "#{work_history_failure_reason}_work_history_checked": [1],
          "#{decline_failure_reason}_checked": true,
          "#{decline_failure_reason}_notes": "Notes",
        }
      end

      it { is_expected.to be_valid }
    end
  end

  describe "#selected_failure_reasons" do
    subject(:selected_failure_reasons) { form.selected_failure_reasons }

    context "when passed" do
      let(:attributes) { { passed: true } }

      it { is_expected.to eq({}) }
    end

    context "when failed" do
      let(:attributes) do
        {
          passed: false,
          "#{further_information_failure_reason}_checked": true,
          "#{further_information_failure_reason}_notes": "Notes.",
        }
      end

      it do
        is_expected.to eq(
          { further_information_failure_reason.to_s => { notes: "Notes." } },
        )
      end
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    describe "when invalid attributes" do
      it { is_expected.to be false }
    end

    describe "with valid attributes and passed" do
      let(:attributes) do
        {
          passed: true,
          "#{further_information_failure_reason}_checked": true,
          "#{further_information_failure_reason}_notes": "Notes.",
        }
      end

      it { is_expected.to be true }

      it "calls the update assessment service" do
        expect(AssessAssessmentSection).to receive(:call).with(
          assessment_section,
          user:,
          passed: true,
          selected_failure_reasons: {
          },
        )

        save # rubocop:disable Rails/SaveBang
      end
    end

    describe "with valid attributes and failed" do
      let(:attributes) do
        {
          :passed => false,
          :"#{further_information_failure_reason}_checked" => true,
          :"#{further_information_failure_reason}_notes" => "Notes.",
          :"#{work_history_failure_reason}_checked" => false,
          "#{decline_failure_reason}_checked" => false,
        }
      end

      it { is_expected.to be true }

      it "calls the update assessment service" do
        expect(AssessAssessmentSection).to receive(:call).with(
          assessment_section,
          user:,
          passed: false,
          selected_failure_reasons: {
            further_information_failure_reason.to_s => {
              notes: "Notes.",
            },
          },
        )

        save # rubocop:disable Rails/SaveBang
      end
    end
  end
end
