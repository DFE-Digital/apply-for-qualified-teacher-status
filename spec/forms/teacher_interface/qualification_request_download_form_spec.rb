# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::QualificationRequestDownloadForm,
               type: :model do
  let(:qualification_request) { create(:qualification_request) }

  subject(:form) { described_class.new(qualification_request:, downloaded:) }

  describe "validations" do
    let(:downloaded) { "" }

    it { is_expected.to validate_presence_of(:qualification_request) }
    it { is_expected.to validate_presence_of(:downloaded) }
  end

  describe "#save" do
    subject(:save) { form.save(validate: false) }

    context "with a positive response" do
      let(:downloaded) { "true" }

      it "sets unsigned_consent_document_downloaded" do
        expect { save }.to change(
          qualification_request,
          :unsigned_consent_document_downloaded,
        ).to(true)
      end
    end

    context "with a negative response" do
      let(:downloaded) { "false" }

      it "doesn't set unsigned_consent_document_downloaded" do
        expect { save }.to_not change(
          qualification_request,
          :unsigned_consent_document_downloaded,
        )
      end
    end
  end
end
