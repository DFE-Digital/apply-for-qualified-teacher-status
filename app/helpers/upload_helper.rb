# frozen_string_literal: true

module UploadHelper
  def upload_link_to(upload)
    href =
      govuk_link_to(
        "#{upload.filename} (opens in a new tab)",
        upload_path(upload),
        target: :_blank,
        rel: :noopener,
      )

    if upload.malware_scan_error? || upload.malware_scan_suspect?
      href +
        tag.p("There’s a problem with this file", class: "govuk-error-message")
    else
      href
    end
  end

  def upload_path(upload)
    interface =
      if request.path.start_with?("/assessor/")
        :assessor_interface
      else
        :teacher_interface
      end
    [interface, :application_form, upload.document, upload]
  end
end
