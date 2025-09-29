# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateNote do
  subject(:call) do
    described_class.call(application_form:, eligibility_domain:, author:, text:)
  end

  let(:application_form) { create(:application_form, :submitted) }
  let(:eligibility_domain) { nil }
  let(:author) { create(:staff) }
  let(:text) { "Note text." }

  describe "record note" do
    subject(:note) { Note.find_by(application_form:) }

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.not_to be_nil }

      it "sets the attributes correctly" do
        expect(note.text).to eq(text)
        expect(note.application_form).to eq(application_form)
      end
    end

    it "records a timeline event" do
      expect { call }.to have_recorded_timeline_event(
        :note_created,
        creator: author,
      )
    end

    context "for eligibility domain" do
      let(:application_form) { nil }
      let(:eligibility_domain) { create(:eligibility_domain) }

      it { is_expected.to be_nil }

      context "after calling the service" do
        before { call }

        it { is_expected.not_to be_nil }

        it "sets the attributes correctly" do
          expect(note.text).to eq(text)
          expect(note.eligibility_domain).to eq(eligibility_domain)
        end
      end

      it "records a timeline event" do
        expect { call }.to have_recorded_timeline_event(
          :note_created,
          creator: author,
        )
      end
    end
  end
end
