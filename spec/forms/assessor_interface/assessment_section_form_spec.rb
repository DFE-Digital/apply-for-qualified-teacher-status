# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::AssessmentSectionForm, type: :model do
  subject(:form) do
    described_class.for_assessment_section(assessment_section).new(
      assessment_section:,
      user:,
      **attributes,
    )
  end

  let!(:work_histories) do
    create_list :work_history,
                2,
                application_form: assessment_section.assessment.application_form
  end

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
        FailureReasons::WORK_HISTORY_REFERENCE_FAILURE_REASONS
    ).sample.to_sym
  end
  let(:work_history_failure_reason) do
    FailureReasons::WORK_HISTORY_REFERENCE_FAILURE_REASONS.sample.to_sym
  end
  let(:decline_failure_reason) { FailureReasons::AGE_RANGE.to_sym }
  let(:user) { create(:staff) }
  let(:attributes) { {} }

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
          "#{work_history_failure_reason}_work_history_#{work_histories.first.id}_checked":
            true,
          "#{work_history_failure_reason}_work_history_#{work_histories.last.id}_checked":
            true,
          "#{decline_failure_reason}_checked": true,
        }
      end

      it do
        expect(subject).to validate_presence_of(
          :"#{further_information_failure_reason}_notes",
        )
      end

      it do
        work_histories.each do |work_history|
          expect(subject).to validate_presence_of(
            :"#{work_history_failure_reason}_work_history_#{work_history.id}_notes",
          ).with_message("Enter a note to the applicant")
        end
      end

      it do
        expect(subject).not_to validate_presence_of(
          :"#{decline_failure_reason}_notes",
        )
      end
    end

    context "when no work history items are checked work history reference failure is selected" do
      let(:attributes) do
        {
          passed: false,
          "#{further_information_failure_reason}_checked": true,
          "#{work_history_failure_reason}_checked": true,
          "#{decline_failure_reason}_checked": true,
        }
      end

      it do
        subject.valid?

        expect(
          subject.errors[
            :"#{work_history_failure_reason}_work_history_checked"
          ],
        ).to include(
          "Select at least one school that we were unable to verify the reference for",
        )
      end
    end

    context "when reasons are checked and notes are provided" do
      let(:attributes) do
        {
          passed: false,
          "#{further_information_failure_reason}_checked": true,
          "#{further_information_failure_reason}_notes": "Notes.",
          "#{work_history_failure_reason}_work_history_#{work_histories.first.id}_checked":
            true,
          "#{work_history_failure_reason}_work_history_#{work_histories.first.id}_notes":
            "Notes.",
          "#{work_history_failure_reason}_work_history_#{work_histories.last.id}_checked":
            true,
          "#{work_history_failure_reason}_work_history_#{work_histories.last.id}_notes":
            "Notes.",
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
        expect(subject).to eq(
          {
            further_information_failure_reason.to_s => {
              assessor_feedback: "Notes.",
            },
          },
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
          :"#{work_history_failure_reason}_checked" => true,
          :"#{work_history_failure_reason}_work_history_#{work_histories.first.id}_checked" =>
            true,
          :"#{work_history_failure_reason}_work_history_#{work_histories.first.id}_notes" =>
            "Notes.",
          :"#{work_history_failure_reason}_work_history_#{work_histories.last.id}_checked" =>
            false,
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
              assessor_feedback: "Notes.",
            },
            work_history_failure_reason.to_s => {
              work_history_failure_reasons: [
                {
                  assessor_feedback: "Notes.",
                  work_history_id: work_histories.first.id,
                },
              ],
            },
          },
        )

        save # rubocop:disable Rails/SaveBang
      end
    end
  end

  describe "initial attributes for assessment section loaded" do
    let(:attributes) { described_class.initial_attributes(assessment_section) }

    it "returns all relevant attributes empty" do
      expect(form).to have_attributes(
        passed: nil,
        "#{further_information_failure_reason}_checked": nil,
        "#{further_information_failure_reason}_notes": nil,
        "#{work_history_failure_reason}_checked": nil,
        "#{work_history_failure_reason}_work_history_#{work_histories.first.id}_checked":
          nil,
        "#{work_history_failure_reason}_work_history_#{work_histories.first.id}_notes":
          nil,
        "#{work_history_failure_reason}_work_history_#{work_histories.last.id}_checked":
          nil,
        "#{work_history_failure_reason}_work_history_#{work_histories.last.id}_notes":
          nil,
        "#{decline_failure_reason}_checked": nil,
        "#{decline_failure_reason}_notes": nil,
      )
    end

    context "when assessment section has been reviewed" do
      let(:assessment_section) do
        create(
          :assessment_section,
          key: "personal_information",
          passed: false,
          failure_reasons: [
            further_information_failure_reason,
            work_history_failure_reason,
            decline_failure_reason,
          ],
          selected_failure_reasons: [
            build(
              :selected_failure_reason,
              key: further_information_failure_reason,
              assessor_feedback: "Note.",
            ),
            build(
              :selected_failure_reason,
              key: work_history_failure_reason,
              assessor_feedback: "Note.",
            ),
          ],
        )
      end

      before do
        assessment_section
          .selected_failure_reasons
          .find_by(key: work_history_failure_reason)
          .update!(work_histories:)
      end

      it "returns all relevant attributes" do
        expect(form).to have_attributes(
          passed: false,
          "#{further_information_failure_reason}_checked": true,
          "#{further_information_failure_reason}_notes": "Note.",
          "#{work_history_failure_reason}_checked": true,
          "#{work_history_failure_reason}_work_history_#{work_histories.first.id}_checked":
            true,
          "#{work_history_failure_reason}_work_history_#{work_histories.first.id}_notes":
            "Note.",
          "#{work_history_failure_reason}_work_history_#{work_histories.last.id}_checked":
            true,
          "#{work_history_failure_reason}_work_history_#{work_histories.last.id}_notes":
            "Note.",
          "#{decline_failure_reason}_checked": nil,
          "#{decline_failure_reason}_notes": nil,
        )
      end
    end

    context "when failure reason used to trigger work history selection but no longer does" do
      let(:work_history_failure_reason) { :school_details_cannot_be_verified }

      let(:assessment_section) do
        create(
          :assessment_section,
          key: "personal_information",
          passed: false,
          failure_reasons: [
            further_information_failure_reason,
            work_history_failure_reason,
            decline_failure_reason,
          ],
          selected_failure_reasons: [
            build(
              :selected_failure_reason,
              key: work_history_failure_reason,
              assessor_feedback: "Note.",
            ),
          ],
        )
      end

      before do
        assessment_section
          .selected_failure_reasons
          .find_by(key: work_history_failure_reason)
          .update!(work_histories:)
      end

      it "returns all relevant attributes" do
        expect(form).to have_attributes(
          passed: false,
          "#{further_information_failure_reason}_checked": nil,
          "#{further_information_failure_reason}_notes": nil,
          "#{work_history_failure_reason}_checked": true,
          "#{work_history_failure_reason}_work_history_#{work_histories.first.id}_checked":
            true,
          "#{work_history_failure_reason}_work_history_#{work_histories.first.id}_notes":
            "Note.",
          "#{work_history_failure_reason}_work_history_#{work_histories.last.id}_checked":
            true,
          "#{work_history_failure_reason}_work_history_#{work_histories.last.id}_notes":
            "Note.",
          "#{decline_failure_reason}_checked": nil,
          "#{decline_failure_reason}_notes": nil,
        )
      end
    end
  end
end
