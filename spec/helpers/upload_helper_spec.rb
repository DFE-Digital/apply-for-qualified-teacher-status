require "rails_helper"

RSpec.describe UploadHelper do
  describe "#upload_link_to" do
    let(:upload) { build_stubbed(:upload) }

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
