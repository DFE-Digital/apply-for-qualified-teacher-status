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

      items = uploads.map { |upload| upload_link_to(upload) }

      if malware_scan_active && scope.malware_scan_suspect.exists?
        items << tag.em(
          "#{scope.count} #{"file upload".pluralize(scope.count)} has been scanned as malware and deleted.",
        )
      end

      tag.ul(class: "govuk-list") { items.map { |item| concat(tag.li(item)) } }
    end
  end
end
