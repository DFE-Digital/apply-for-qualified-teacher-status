# frozen_string_literal: true

require "rails_helper"

RSpec.describe FurtherInformationRequestItemsFactory do
  subject(:items) { described_class.call(assessment_sections:) }

  context "with no assessment sections" do
    let(:assessment_sections) { [] }

    it { is_expected.to be_empty }
  end

  context "with assessment sections" do
    let(:assessment_sections) do
      [
        create(
          :assessment_section,
          :personal_information,
          :failed,
          selected_failure_reasons: {
            identification_document_expired: "Expired.",
          },
        ),
        create(
          :assessment_section,
          :qualifications,
          :failed,
          selected_failure_reasons: {
            qualifications_dont_match_subjects: "Subjects.",
          },
        ),
      ]
    end

    it { is_expected.to_not be_empty }

    describe "first item" do
      subject(:item) { items.first }

      it "has attributes" do
        expect(item).to be_document
        expect(item.failure_reason).to eq("identification_document_expired")
        expect(item.assessor_notes).to eq("Expired.")
        expect(item.document.identification?).to be true
      end
    end

    describe "second item" do
      subject(:item) { items.second }

      it "has attributes" do
        expect(item).to be_text
        expect(item.failure_reason).to eq("qualifications_dont_match_subjects")
        expect(item.assessor_notes).to eq("Subjects.")
      end
    end
  end
end
