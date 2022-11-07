require "rails_helper"

RSpec.describe FileUploadValidator do
  before do
    stub_const("Validatable", Class.new).class_eval do
      include ActiveModel::Validations
      attr_accessor :file
      validates :file, file_upload: true
    end
  end

  subject(:model) { Validatable.new }

  before { model.file = file }

  context "with a valid file" do
    let(:file) do
      ActionDispatch::Http::UploadedFile.new(
        tempfile: file_fixture("upload.pdf"),
        type: "application/pdf",
        filename: "upload.pdf",
      )
    end

    it { is_expected.to be_valid }
  end

  context "with a valid file with an uppercase extension" do
    let(:file) do
      ActionDispatch::Http::UploadedFile.new(
        tempfile: file_fixture("id_example.JPG"),
        type: "image/jpeg",
        filename: "id_example.JPG",
      )
    end

    it { is_expected.to be_valid }
  end

  context "with a jpeg extension" do
    let(:file) do
      ActionDispatch::Http::UploadedFile.new(
        tempfile: file_fixture("id_example.JPG"),
        type: "image/jpeg",
        filename: "id_example.jpeg",
      )
    end

    it { is_expected.to be_valid }
  end

  context "with an invalid content type" do
    let(:file) do
      ActionDispatch::Http::UploadedFile.new(
        tempfile: file_fixture("upload.txt"),
        type: "text/plain",
        filename: "upload.txt",
      )
    end

    it { is_expected.to_not be_valid }
  end

  context "with an invalid extension" do
    let(:file) do
      ActionDispatch::Http::UploadedFile.new(
        tempfile: file_fixture("upload.txt"),
        type: "application/pdf",
        filename: "upload.txt",
      )
    end

    it { is_expected.to_not be_valid }
  end

  context "with a large file" do
    let(:file) do
      ActionDispatch::Http::UploadedFile.new(
        tempfile: file_fixture("upload.pdf"),
        type: "application/pdf",
        filename: "upload.pdf",
      )
    end

    before { allow(file).to receive(:size).and_return(50 * 1024 * 1024) }

    it { is_expected.to_not be_valid }
  end
end
