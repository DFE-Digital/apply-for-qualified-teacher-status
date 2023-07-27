# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::AssessmentSectionForm, type: :model do
  let(:assessment_section) do
    create(
      :assessment_section,
      key: "personal_information",
      failure_reasons: [:reason_a, :reason_b, decline_failure_reason],
    )
  end
  let(:decline_failure_reason) { FailureReasons::DECLINABLE.sample.to_sym }
  let(:user) { create(:staff, :confirmed) }
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
          :passed => false,
          :reason_a_checked => true,
          :reason_b_checked => true,
          "#{decline_failure_reason}_checked".to_sym => true,
        }
      end

      it { is_expected.to validate_presence_of(:reason_a_notes) }
      it { is_expected.to validate_presence_of(:reason_b_notes) }
      it do
        is_expected.not_to validate_presence_of(
          "#{decline_failure_reason}_notes".to_sym,
        )
      end
    end

    context "when reasons are checked and notes are provided" do
      let(:attributes) do
        {
          :passed => false,
          :reason_a_checked => true,
          :reason_a_notes => "Notes.",
          :reason_b_checked => true,
          :reason_b_notes => "Notes.",
          "#{decline_failure_reason}_checked".to_sym => true,
          "#{decline_failure_reason}_notes".to_sym => "Notes",
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
        { passed: false, reason_a_checked: true, reason_a_notes: "Notes." }
      end

      it { is_expected.to eq({ "reason_a" => {notes: "Notes." }}) }
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    describe "when invalid attributes" do
      it { is_expected.to be false }
    end

    describe "with valid attributes and passed" do
      let(:attributes) do
        { passed: true, reason_a_checked: true, reason_a_notes: "Notes." }
      end

      it { is_expected.to be true }

      it "calls the update assessment service" do
        expect(UpdateAssessmentSection).to receive(:call).with(
          assessment_section:,
          user:,
          params: {
            passed: true,
            selected_failure_reasons: {
            },
          },
        )

        save # rubocop:disable Rails/SaveBang
      end
    end

    describe "with valid attributes and failed" do
      let(:attributes) do
        {
          :passed => false,
          :reason_a_checked => true,
          :reason_a_notes => "Notes.",
          :reason_b_checked => false,
          "#{decline_failure_reason}_checked" => false,
        }
      end

      it { is_expected.to be true }

      it "calls the update assessment service" do
        expect(UpdateAssessmentSection).to receive(:call).with(
          assessment_section:,
          user:,
          params:
               {passed: false,
                selected_failure_reasons: {"reason_a"=>{notes: "Notes."}
                }

        }
        )

        save # rubocop:disable Rails/SaveBang
      end
    end
  end
end
