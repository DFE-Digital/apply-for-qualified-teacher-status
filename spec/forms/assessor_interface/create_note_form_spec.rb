require "rails_helper"

RSpec.describe AssessorInterface::CreateNoteForm, type: :model do
  let(:application_form) { create(:application_form) }
  let(:author) { create(:staff, :confirmed) }
  let(:text) { "A note." }

  subject { described_class.new(application_form:, author:, text:) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to validate_presence_of(:author) }
    it { is_expected.to validate_presence_of(:text) }
  end

  describe "#save" do
    let(:note) { Note.last }

    it "creates a note" do
      expect { subject.save }.to change { Note.count }.by(1)

      expect(note.application_form).to eq(application_form)
      expect(note.author).to eq(author)
      expect(note.text).to eq(text)
    end

    it "records a timeline event" do
      expect { subject.save }.to have_recorded_timeline_event(
        :note_created,
        creator: author,
      )
    end
  end
end
