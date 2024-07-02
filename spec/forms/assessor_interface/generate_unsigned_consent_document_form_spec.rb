# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::GenerateUnsignedConsentDocumentForm,
               type: :model do
  subject(:form) { described_class.new(assessment:, generated:) }

  let(:assessment) { create(:assessment) }

  describe "validations" do
    let(:generated) { "" }

    it { is_expected.to validate_presence_of(:assessment) }
    it { is_expected.to validate_presence_of(:generated) }
  end

  describe "#save" do
    subject(:save) { form.save }

    context "with a positive response" do
      let(:generated) { "true" }

      it "sets unsigned_consent_document_downloaded" do
        expect { save }.to change(
          assessment,
          :unsigned_consent_document_generated,
        ).to(true)
      end
    end

    context "with a negative response" do
      let(:generated) { "false" }

      it "doesn't set unsigned_consent_document_downloaded" do
        expect { save }.not_to change(
          assessment,
          :unsigned_consent_document_generated,
        )
      end
    end
  end
end
