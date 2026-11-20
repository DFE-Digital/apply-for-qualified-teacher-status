# frozen_string_literal: true

require "rails_helper"

RSpec.describe FileUploadValidator do
  subject(:model) { Validatable.new }

  before do
    stub_const("Validatable", Class.new).class_eval do
      include ActiveModel::Validations
      attr_accessor :file
      validates :file, file_upload: true
    end
    model.file = file
  end

  context "with a valid file" do
    let(:file) { fixture_file_upload("upload.pdf", "application/pdf") }

    it { is_expected.to be_valid }
  end

  context "with a valid file with an uppercase extension" do
    let(:file) { fixture_file_upload("id_example.JPG", "image/jpeg") }

    it { is_expected.to be_valid }
  end

  context "with an invalid content type" do
    let(:file) { fixture_file_upload("upload.txt", "text/plain") }

    it { is_expected.not_to be_valid }
  end

  context "with an invalid extension" do
    let(:file) { fixture_file_upload("upload.txt", "application/pdf") }

    it { is_expected.not_to be_valid }
  end

  context "with a large file" do
    let(:file) { fixture_file_upload("upload.pdf", "application/pdf") }

    before { allow(file).to receive(:size).and_return(50 * 1024 * 1024) }

    it { is_expected.not_to be_valid }
  end

  context "with a small file" do
    let(:file) { fixture_file_upload("upload.pdf", "application/pdf") }

    before { allow(file).to receive(:size).and_return(1) }

    it { is_expected.not_to be_valid }
  end

  describe "pdfinfo invocation" do
    let(:file) { fixture_file_upload("upload.pdf", "application/pdf") }
    let(:status) { instance_double(Process::Status, success?: true) }

    it "invokes pdfinfo without a shell" do
      allow(Open3).to receive(:capture2).and_return(["Encrypted: no\n", status])

      expect(model).to be_valid
      expect(Open3).to have_received(:capture2).with(
        "pdfinfo",
        file.path,
        err: File::NULL,
      )
    end

    it "accepts the file when pdfinfo is missing" do
      allow(Open3).to receive(:capture2).and_raise(Errno::ENOENT)

      expect(model).to be_valid
    end

    it "accepts the file when pdfinfo fails without output" do
      allow(status).to receive(:success?).and_return(false)
      allow(Open3).to receive(:capture2).and_return(["", status])

      expect(model).to be_valid
    end

    it "rejects an encrypted PDF" do
      allow(Open3).to receive(:capture2).and_return(
        ["Encrypted: yes\n", status],
      )

      expect(model).not_to be_valid
      expect(model.errors.of_kind?(:file, :encrypted_pdf)).to be true
    end

    it "checks the output even when pdfinfo fails" do
      allow(status).to receive(:success?).and_return(false)
      allow(Open3).to receive(:capture2).and_return(
        ["Encrypted: yes\n", status],
      )

      expect(model).not_to be_valid
      expect(model.errors.of_kind?(:file, :encrypted_pdf)).to be true
    end

    it "only checks lines starting with Encrypted" do
      allow(Open3).to receive(:capture2).and_return(
        ["Title: Encrypted yes\nEncrypted: no\n", status],
      )

      expect(model).to be_valid
    end

    context "with a non-PDF file" do
      let(:file) { fixture_file_upload("upload.txt", "text/plain") }

      it "invokes pdfinfo after checking the content type" do
        expect(Open3).to receive(:capture2).with(
          "pdfinfo",
          file.path,
          err: File::NULL,
        ) do
          expect(model.errors.of_kind?(:file, :invalid_content_type)).to be true
          ["", status]
        end

        expect(model).not_to be_valid
      end
    end
  end
end
