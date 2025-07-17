# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::PrioritisationWorkHistoryCheckForm,
               type: :model do
  subject(:form) do
    described_class.for_prioritisation_work_history_check(
      prioritisation_work_history_check,
    ).new(prioritisation_work_history_check:, **attributes)
  end

  let(:assessment) { create(:assessment) }

  let(:prioritisation_work_history_check) do
    create(
      :prioritisation_work_history_check,
      assessment:,
      failure_reasons: %w[
        prioritisation_work_history_role
        prioritisation_work_history_setting
      ],
    )
  end

  let(:attributes) { {} }

  describe "validations" do
    it do
      expect(subject).to validate_presence_of(
        :prioritisation_work_history_check,
      )
    end

    it { is_expected.to allow_values(true, false).for(:passed) }

    context "when passed" do
      let(:attributes) { { passed: true } }

      it { is_expected.to be_valid }
    end

    context "when not passed" do
      let(:attributes) { { passed: false } }

      it { is_expected.not_to be_valid }

      context "with reasons are checked" do
        let(:attributes) do
          {
            passed: false,
            prioritisation_work_history_role_checked: true,
            prioritisation_work_history_setting_checked: true,
          }
        end

        it { is_expected.to be_valid }
      end
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
          prioritisation_work_history_role_checked: true,
          prioritisation_work_history_role_notes: "Notes",
        }
      end

      it do
        expect(subject).to eq(
          { "prioritisation_work_history_role" => { notes: "Notes" } },
        )
      end
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    context "when passed" do
      let(:attributes) { { passed: true } }

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

      it "does not set any selected prioritisation failure reasons" do
        expect { save }.not_to change(
          prioritisation_work_history_check.selected_failure_reasons,
          :count,
        )
      end
    end

    context "when not passed" do
      let(:attributes) do
        {
          passed: false,
          prioritisation_work_history_role_checked: true,
          prioritisation_work_history_role_notes: "Notes",
        }
      end

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

      it "sets selected prioritisation failure reasons" do
        expect { save }.to change(
          prioritisation_work_history_check.selected_failure_reasons,
          :count,
        ).from(0).to(1)

        expect(
          prioritisation_work_history_check.selected_failure_reasons.first,
        ).to have_attributes(
          key: "prioritisation_work_history_role",
          assessor_feedback: "Notes",
        )
      end
    end
  end

  describe ".initial_attributes" do
    subject(:initial_attributes) do
      described_class.initial_attributes(prioritisation_work_history_check)
    end

    context "when passed" do
      before { prioritisation_work_history_check.update!(passed: true) }

      it "sets the correct attributes" do
        expect(initial_attributes).to eq(
          { prioritisation_work_history_check:, passed: true },
        )
      end
    end

    context "when failed" do
      before do
        prioritisation_work_history_check.update!(passed: false)
        create :selected_failure_reason,
               prioritisation_work_history_check:,
               key: "prioritisation_work_history_role",
               assessor_feedback: "Note"
      end

      it "sets the correct attributes" do
        expect(initial_attributes).to eq(
          {
            prioritisation_work_history_check:,
            passed: false,
            "prioritisation_work_history_role_checked" => true,
            "prioritisation_work_history_role_notes" => "Note",
          },
        )
      end
    end
  end
end
