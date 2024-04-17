require "rails_helper"

RSpec.describe UploadHelper do
  describe "#upload_link_to" do
    subject(:upload_link_to) { helper.upload_link_to(upload) }

    context "when the upload is clean" do
      let(:upload) { build_stubbed(:upload, :clean) }

      it "returns a link to the upload" do
        expect(upload_link_to).to have_link(
          "#{upload.filename} (opens in a new tab)",
          href:
            "/teacher/application/documents/#{upload.document.id}/uploads/#{upload.id}",
        )
      end

      context "via the assessors interface" do
        before do
          allow(helper.request).to receive(:path).and_return(
            "/assessor/application",
          )
        end

        it "returns a link to the upload" do
          expect(upload_link_to).to have_link(
            "#{upload.filename} (opens in a new tab)",
            href:
              "/assessor/application/documents/#{upload.document.id}/uploads/#{upload.id}",
          )
        end
      end
    end

    context "when the upload malware scan is pending" do
      let(:upload) { build_stubbed(:upload, :pending) }

      it "returns text for a pending scan" do
        expect(upload_link_to).to have_content(upload.filename)
      end
    end

    context "when the upload malware scan is suspect" do
      let(:upload) { build_stubbed(:upload, :suspect) }

      it "appends an error for a suspect scan" do
        expect(upload_link_to).to have_content(
          "The selected file contains a suspected virus",
        )
        expect(upload_link_to).to have_css(".govuk-form-group--error")
      end
    end
  end
end
