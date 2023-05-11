require "rails_helper"

RSpec.describe UploadHelper do
  describe "#upload_link_to" do
    let(:upload) { build_stubbed(:upload, :clean) }

    it "returns a link to the upload" do
      link = helper.upload_link_to(upload)

      expect(link).to have_link(
        "#{upload.name} (opens in a new tab)",
        href:
          teacher_interface_application_form_document_upload_path(
            upload.document,
            upload,
          ),
      )
    end

    context "when the upload malware scan is pending" do
      let(:upload) { build_stubbed(:upload, :pending) }
      before { FeatureFlags::FeatureFlag.activate(:fetch_malware_scan_result) }
      it "returns text for a pending scan" do
        link = helper.upload_link_to(upload)
        expect(link).to have_link(
          upload.name,
          href:
            teacher_interface_application_form_document_upload_path(
              upload.document,
              upload,
            ),
        )
      end
    end

    context "when the upload malware scan is suspect" do
      let(:upload) { build_stubbed(:upload, :suspect) }
      before { FeatureFlags::FeatureFlag.activate(:fetch_malware_scan_result) }
      it "appends an error for a suspect scan" do
        link = helper.upload_link_to(upload)
        expect(link).to have_content(
          "#{upload.name}There’s a problem with this file",
        )
        expect(link).to have_css(
          "p.govuk-error-message",
          text: "There’s a problem with this file",
        )
      end
    end

    context "via the assessors interface" do
      it "returns a link to the upload" do
        allow(helper.request).to receive(:path).and_return(
          assessor_interface_application_form_document_upload_path(
            upload.document,
            upload,
          ),
        )

        link = helper.upload_link_to(upload)

        expect(link).to have_link(
          "#{upload.name} (opens in a new tab)",
          href:
            assessor_interface_application_form_document_upload_path(
              upload.document,
              upload,
            ),
        )
      end
    end
  end
end
