# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::DocumentViewObject do
  subject(:view_object) { described_class.new(document:) }

  describe "#section_caption" do
    context "when qualification document" do
      let(:document) { create(:document, :qualification_document) }

      it "returns 'Your qualifications'" do
        expect(view_object.section_caption).to eq("Your qualifications")
      end
    end

    context "when qualification certificate document" do
      let(:document) { create(:document, :qualification_certificate) }

      it "returns 'Your qualifications'" do
        expect(view_object.section_caption).to eq("Your qualifications")
      end
    end

    context "when qualification transacript document" do
      let(:document) { create(:document, :qualification_transcript) }

      it "returns 'Your qualifications'" do
        expect(view_object.section_caption).to eq("Your qualifications")
      end
    end

    context "when name change document" do
      let(:document) { create(:document, :name_change) }

      it "returns 'About you'" do
        expect(view_object.section_caption).to eq("About you")
      end
    end

    context "when passport document" do
      let(:document) { create(:document, :passport) }

      it "returns 'About you'" do
        expect(view_object.section_caption).to eq("About you")
      end
    end

    context "when identification document" do
      let(:document) { create(:document, :identification) }

      it "returns 'About you'" do
        expect(view_object.section_caption).to eq("About you")
      end
    end

    context "when medium of instruction document" do
      let(:document) { create(:document, :medium_of_instruction) }

      it "returns 'Your English language proficiency'" do
        expect(view_object.section_caption).to eq(
          "Your English language proficiency",
        )
      end
    end

    context "when ESOL document" do
      let(:document) do
        create(:document, :english_for_speakers_of_other_languages)
      end

      it "returns 'Your English language proficiency'" do
        expect(view_object.section_caption).to eq(
          "Your English language proficiency",
        )
      end
    end

    context "when English language proficiency document" do
      let(:document) { create(:document, :english_language_proficiency) }

      it "returns 'Your English language proficiency'" do
        expect(view_object.section_caption).to eq(
          "Your English language proficiency",
        )
      end
    end

    context "when written statement document" do
      let(:document) { create(:document, :written_statement) }

      it "returns 'Proof that you’re recognised as a teacher'" do
        expect(view_object.section_caption).to eq(
          "Proof that you’re recognised as a teacher",
        )
      end
    end

    context "when signed_consent document" do
      let(:document) { create(:document, :signed_consent) }

      it "returns nil" do
        expect(view_object.section_caption).to be_nil
      end
    end

    context "when unsigned_consent document" do
      let(:document) { create(:document, :unsigned_consent) }

      it "returns nil" do
        expect(view_object.section_caption).to be_nil
      end
    end
  end
end
