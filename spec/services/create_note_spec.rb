# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateNote do
  let(:application_form) { create(:application_form, :submitted) }
  let(:author) { create(:staff, :confirmed) }
  let(:text) { "Note text." }

  subject(:call) { described_class.call(application_form:, author:, text:) }

  describe "record note" do
    subject(:note) { Note.find_by(application_form:) }

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.to_not be_nil }

      it "sets the attributes correctly" do
        expect(note.text).to eq(text)
      end
    end
  end

  describe "record timeline event" do
    subject(:timeline_event) do
      TimelineEvent.note_created.find_by(application_form:)
    end

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.to_not be_nil }

      it "sets the attributes correctly" do
        expect(timeline_event.creator).to eq(author)
        expect(timeline_event.note).to eq(Note.first)
      end
    end
  end
end
