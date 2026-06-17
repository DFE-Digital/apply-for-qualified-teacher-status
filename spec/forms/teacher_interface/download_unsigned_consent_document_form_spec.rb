# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::DownloadUnsignedConsentDocumentForm,
               type: :model do
  subject(:form) { described_class.new(consent_request:, downloaded:) }

  let(:consent_request) { create(:consent_request) }

  describe "validations" do
    let(:downloaded) { "" }

    it { is_expected.to validate_presence_of(:consent_request) }
    it { is_expected.to validate_presence_of(:downloaded) }
  end

  describe "#save" do
    subject(:save) { form.save(validate: false) }

    context "with a positive response" do
      let(:downloaded) { true }

      it "sets unsigned_document_downloaded" do
        expect { save }.to change(
          consent_request,
          :unsigned_document_downloaded,
        ).to(true)
      end
    end

    context "with a negative response" do
      let(:downloaded) { false }

      it "doesn't set unsigned_document_downloaded" do
        expect { save }.not_to change(
          consent_request,
          :unsigned_document_downloaded,
        )
      end
    end

    context "with nil response" do
      let(:downloaded) { nil }

      it "doesn't set unsigned_document_downloaded" do
        expect { save }.not_to change(
          consent_request,
          :unsigned_document_downloaded,
        )
      end
    end

    context "when unsigned consent already downloaded" do
      let(:consent_request) do
        create(:consent_request, unsigned_document_downloaded: true)
      end

      context "with a positive response" do
        let(:downloaded) { true }

        it "sets does not change unsigned_document_downloaded" do
          expect { save }.not_to change(
            consent_request,
            :unsigned_document_downloaded,
          )
        end
      end

      context "with a negative response" do
        let(:downloaded) { false }

        it "changes unsigned_document_downloaded to false" do
          expect { save }.to change(
            consent_request,
            :unsigned_document_downloaded,
          ).to(false)
        end
      end

      context "with nil response" do
        let(:downloaded) { nil }

        it "changes unsigned_document_downloaded to false" do
          expect { save }.to change(
            consent_request,
            :unsigned_document_downloaded,
          ).to(false)
        end
      end
    end
  end
end
