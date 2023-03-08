# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreatePreliminaryCheckNote do
  let(:application_form) do
    create(
      :application_form,
      :submitted,
      assessment:,
      requires_preliminary_check: true,
    )
  end
  let(:assessment) { create(:assessment) }
  let(:author) { create(:staff, :confirmed) }

  subject(:call) { described_class.call(application_form:, author:) }

  describe "record note" do
    subject(:note) { Note.find_by(application_form:) }

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.to_not be_nil }

      it "sets the text correctly" do
        expect(note.text).to eq(
          I18n.t(
            "assessor_interface.case_notes.preliminary_check.application_submitted",
          ),
        )
      end
    end

    context "when the preliminary check is complete" do
      let(:assessment) { create(:assessment, preliminary_check_complete: true) }

      subject(:call) { described_class.call(application_form:, author:) }

      before { call }

      it "sets the text correctly" do
        expect(note.text).to eq(
          I18n.t("assessor_interface.case_notes.preliminary_check.complete"),
        )
      end
    end

    context "when the preliminary check is complete and the professional standing request has been received" do
      let(:assessment) { create(:assessment, preliminary_check_complete: true) }
      subject(:call) { described_class.call(application_form:, author:) }

      before do
        create(:professional_standing_request, :requested, assessment:)
        call
      end

      it "sets the text correctly" do
        expect(note.text).to eq(
          I18n.t(
            "assessor_interface.case_notes.preliminary_check.complete_waiting_for_professional_standing",
          ),
        )
      end
    end
  end

  it "records a timeline event" do
    expect { call }.to have_recorded_timeline_event(
      :note_created,
      creator: author,
    )
  end
end
