# frozen_string_literal: true

module DocumentHelper
  include UploadHelper

  def document_link_to(document, translated: false)
    scope =
      (
        if translated
          document.translated_uploads
        else
          document.original_uploads
        end
      )

    if document.optional? && !document.available
      "<em>The applicant has indicated that they haven't done an induction period " \
        "and don't have this document.</em>".html_safe
    else
      uploads =
        scope.order(:created_at).select { |upload| upload.attachment.present? }

      malware_scan_active =
        FeatureFlags::FeatureFlag.active?(:fetch_malware_scan_result)
      convert_to_pdf_active =
        FeatureFlags::FeatureFlag.active?(:convert_documents_to_pdf)

      [
        uploads
          .map { |upload| upload_link_to(upload) }
          .join("<br />")
          .html_safe,
        if malware_scan_active && scope.scan_result_suspect.exists?
          "<em>#{scope.count} #{"file upload".pluralize(scope.count)} has been scanned as malware and deleted.</em>"
        elsif request.path.starts_with?("/assessor") && convert_to_pdf_active &&
              !uploads.all?(&:is_pdf?)
          govuk_link_to(
            "Download as PDF (opens in a new tab)",
            Rails
              .application
              .routes
              .url_helpers
              .assessor_interface_application_form_document_pdf_path(
              document,
              translated ? "translated" : "original",
            ),
            target: :_blank,
            rel: :noopener,
          )
        end,
      ].compact_blank.join("<br /><br />").html_safe
    end
  end
end
