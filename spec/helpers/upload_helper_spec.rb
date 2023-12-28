require "rails_helper"

RSpec.describe UploadHelper do
  describe "#upload_link_to" do
    subject(:upload_link_to) { helper.upload_link_to(upload) }

    context "when the upload is clean" do
      let(:upload) { build_stubbed(:upload, :clean) }

      it "returns a link to the upload" do
        expect(upload_link_to).to have_link(
          "#{upload.name} (opens in a new tab)",
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
            "#{upload.name} (opens in a new tab)",
            href:
              "/assessor/application/documents/#{upload.document.id}/uploads/#{upload.id}",
          )
        end
      end
    end

    context "when the upload malware scan is pending" do
      let(:upload) { build_stubbed(:upload, :pending) }

      before { FeatureFlags::FeatureFlag.activate(:fetch_malware_scan_result) }

      it "returns text for a pending scan" do
        expect(upload_link_to).to have_link(
          upload.name,
          href:
            "/teacher/application/documents/#{upload.document.id}/uploads/#{upload.id}",
        )
      end
    end

    context "when the upload malware scan is suspect" do
      let(:upload) { build_stubbed(:upload, :suspect) }

      before { FeatureFlags::FeatureFlag.activate(:fetch_malware_scan_result) }

      it "appends an error for a suspect scan" do
        expect(upload_link_to).to have_content(
          "There’s a problem with this file",
        )
        expect(upload_link_to).to have_css(
          "p.govuk-error-message",
          text: "There’s a problem with this file",
        )
      end
    end
  end
end
