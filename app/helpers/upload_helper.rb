module UploadHelper
  def upload_link_to(upload)
    return "Suspected malware. File removed." if upload.scan_result_suspect?

    govuk_link_to(
      "#{upload.name} (opens in a new tab)",
      [interface, :application_form, upload.document, upload],
      target: :_blank,
      rel: :noopener,
    )
  end

  def interface
    if request.path.start_with?("/assessor/")
      :assessor_interface
    else
      :teacher_interface
    end
  end
end
