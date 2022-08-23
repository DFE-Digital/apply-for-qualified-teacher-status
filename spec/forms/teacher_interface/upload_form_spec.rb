require "spec_helper"

RSpec.describe TeacherInterface::UploadForm, type: :model do
  subject(:upload_form) do
    described_class.new(document:, original_attachment:, translated_attachment:)
  end

  let(:document) { create(:document) }
  let(:original_attachment) { nil }
  let(:translated_attachment) { nil }

  it { is_expected.to validate_presence_of(:document) }

  describe "#valid?" do
    subject(:valid?) { upload_form.valid? }

    context "with nil attachments" do
      it { is_expected.to be true }
    end

    context "with an original attachment" do
      let(:original_attachment) do
        ActionDispatch::Http::UploadedFile.new(
          tempfile: file_fixture("upload.pdf"),
          type: "application/pdf"
        )
      end

      it { is_expected.to be true }
    end

    context "with an translated attachment" do
      let(:translated_attachment) do
        ActionDispatch::Http::UploadedFile.new(
          tempfile: file_fixture("upload.pdf"),
          type: "application/pdf"
        )
      end

      it { is_expected.to be true }
    end

    context "with an invalid content type" do
      let(:original_attachment) do
        ActionDispatch::Http::UploadedFile.new(
          tempfile: file_fixture("upload.txt"),
          type: "text/plain"
        )
      end

      it { is_expected.to be false }
    end

    context "with a large file" do
      let(:original_attachment) do
        ActionDispatch::Http::UploadedFile.new(
          tempfile: file_fixture("upload.pdf"),
          type: "application/pdf"
        )
      end

      before do
        allow(original_attachment).to receive(:size).and_return(
          50 * 1024 * 1024
        )
      end

      it { is_expected.to be false }
    end
  end

  describe "#save" do
    before { upload_form.save }

    context "with an original attachment" do
      let(:original_attachment) do
        ActionDispatch::Http::UploadedFile.new(
          tempfile: file_fixture("upload.pdf"),
          filename: "upload.pdf",
          type: "application/pdf"
        )
      end

      it "creates an upload" do
        expect(document.uploads.count).to eq(1)
        expect(document.uploads.first.translation).to be(false)
      end
    end

    context "with a translated attachment" do
      let(:translated_attachment) do
        ActionDispatch::Http::UploadedFile.new(
          tempfile: file_fixture("upload.pdf"),
          filename: "upload.pdf",
          type: "application/pdf"
        )
      end

      it "creates an upload" do
        expect(document.uploads.count).to eq(1)
        expect(document.uploads.first.translation).to be(true)
      end
    end
  end
end
