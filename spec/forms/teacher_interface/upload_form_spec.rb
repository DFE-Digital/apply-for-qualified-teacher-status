# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::UploadForm, type: :model do
  subject(:upload_form) do
    described_class.new(
      document:,
      original_attachment:,
      translated_attachment:,
      written_in_english:,
    )
  end

  let(:document) { create(:document, :identification) }
  let(:original_attachment) { nil }
  let(:translated_attachment) { nil }
  let(:written_in_english) { nil }

  it { is_expected.to validate_presence_of(:document) }

  describe "validations" do
    it { is_expected.to validate_absence_of(:written_in_english) }

    context "with a translatable document" do
      let(:document) { create(:document, :translatable) }

      it { is_expected.to allow_values(true, false).for(:written_in_english) }
    end
  end

  describe "#valid?" do
    subject(:valid?) { upload_form.valid? }

    context "with nil attachments" do
      it { is_expected.to be false }
    end

    context "with an original attachment" do
      let(:original_attachment) do
        fixture_file_upload("upload.pdf", "application/pdf")
      end

      it { is_expected.to be true }
    end

    context "with an translated attachment" do
      let(:original_attachment) do
        fixture_file_upload("upload.pdf", "application/pdf")
      end
      let(:translated_attachment) do
        fixture_file_upload("upload.pdf", "application/pdf")
      end

      it { is_expected.to be true }
    end

    context "written_in_english 'No'" do
      let(:written_in_english) { "false" }
      let(:original_attachment) do
        fixture_file_upload("upload.pdf", "application/pdf")
      end

      it { is_expected.to be false }
    end

    context "with an invalid content type" do
      let(:original_attachment) do
        fixture_file_upload("upload.txt", "text/plain")
      end

      it { is_expected.to be false }
    end

    context "with an invalid extension" do
      let(:original_attachment) do
        fixture_file_upload("upload.txt", "application/pdf")
      end

      it { is_expected.to be false }
    end

    context "with a large file" do
      let(:original_attachment) do
        fixture_file_upload("upload.pdf", "application/pdf")
      end

      before do
        allow(original_attachment).to receive(:size).and_return(
          50 * 1024 * 1024,
        )
      end

      it { is_expected.to be false }
    end
  end

  describe "#save" do
    before { upload_form.save(validate: true) }

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

    context "with a translated attachment" do
      let(:original_attachment) do
        fixture_file_upload("upload.pdf", "application/pdf")
      end

      let(:translated_attachment) do
        fixture_file_upload("upload.pdf", "application/pdf")
      end

      it "creates two uploads" do
        expect(document.uploads.count).to eq(2)
        expect(document.uploads.second.translation).to be(true)
      end

      it "marks the document as complete" do
        expect(document.completed?).to be true
      end
    end

    context "when an error is raised" do
      let(:original_attachment) do
        fixture_file_upload("upload.pdf", "application/pdf")
      end

      shared_examples_for "a timeout error" do
        before do
          allow(upload_form).to receive(:update_model).and_raise(timeout_error)
        end

        it "sets the timeout_error attribute" do
          expect(upload_form.save(validate: true)).to be false
          expect(upload_form.timeout_error).to be true
        end
      end

      context "with a Faraday::ConnectionFailed" do
        let(:timeout_error) { Faraday::ConnectionFailed.new(nil, nil) }

        it_behaves_like "a timeout error"
      end

      context "with a Faraday::TimeoutError" do
        let(:timeout_error) { Faraday::TimeoutError.new }

        it_behaves_like "a timeout error"
      end

      context "with a Net::ReadTimeout" do
        let(:timeout_error) { Net::ReadTimeout.new }

        it_behaves_like "a timeout error"
      end

      context "with a Net::WriteTimeout" do
        let(:timeout_error) { Net::WriteTimeout.new }

        it_behaves_like "a timeout error"
      end
    end
  end
end
