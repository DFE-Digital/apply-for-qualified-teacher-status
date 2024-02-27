# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::UploadUnsignedConsentDocumentForm,
               type: :model do
  subject(:form) { described_class.new(consent_request:, original_attachment:) }

  let(:consent_request) { create(:consent_request) }
  let(:document) { consent_request.unsigned_consent_document }
  let(:original_attachment) { nil }

  it { is_expected.to validate_presence_of(:consent_request) }

  describe "validations" do
    it { is_expected.to validate_absence_of(:written_in_english) }
  end

  describe "#valid?" do
    subject(:valid?) { form.valid? }

    context "with nil attachments" do
      it { is_expected.to be false }
    end

    context "with an original attachment" do
      let(:original_attachment) do
        fixture_file_upload("upload.pdf", "application/pdf")
      end

      it { is_expected.to be true }
    end
  end

  describe "#save" do
    before { form.save }

    context "with an original attachment" do
      let(:original_attachment) do
        fixture_file_upload("upload.pdf", "application/pdf")
      end

      it "creates an upload" do
        expect(document.uploads.count).to eq(1)
        expect(document.uploads.first.translation).to be(false)
      end

      it "marks the document as complete" do
        expect(document.completed?).to be true
      end
    end
  end
end
