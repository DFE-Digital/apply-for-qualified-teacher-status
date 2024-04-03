# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateNote do
  let(:application_form) { create(:application_form, :submitted) }
  let(:author) { create(:staff) }
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

  it "records a timeline event" do
    expect { call }.to have_recorded_timeline_event(
      :note_created,
      creator: author,
    )
  end
end
