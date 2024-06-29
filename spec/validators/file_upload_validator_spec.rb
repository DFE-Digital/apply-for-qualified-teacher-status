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
end
