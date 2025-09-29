# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::CreateNoteForm, type: :model do
  subject do
    described_class.new(application_form:, eligibility_domain:, author:, text:)
  end

  let(:application_form) { create(:application_form) }
  let(:eligibility_domain) { nil }
  let(:author) { create(:staff) }
  let(:text) { "A note." }

  describe "validations" do
    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to validate_presence_of(:author) }
    it { is_expected.to validate_presence_of(:text) }

    it { is_expected.not_to validate_presence_of(:eligibility_domain) }

    context "when application form is not present and eligibility_domain is" do
      let(:application_form) { nil }
      let(:eligibility_domain) { create(:eligibility_domain) }

      it { is_expected.not_to validate_presence_of(:application_form) }
      it { is_expected.to validate_presence_of(:eligibility_domain) }
    end
  end

  describe "#save" do
    let(:note) { Note.last }

    it "creates a note for application form" do
      expect { subject.save }.to change(Note, :count).by(1)

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

    context "for eligibility domain" do
      let(:application_form) { nil }
      let(:eligibility_domain) { create(:eligibility_domain) }

      it "creates a note for eligibility domain" do
        expect { subject.save }.to change(Note, :count).by(1)

        expect(note.eligibility_domain).to eq(eligibility_domain)
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
end
