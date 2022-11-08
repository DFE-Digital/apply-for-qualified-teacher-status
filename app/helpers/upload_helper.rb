module UploadHelper
  def upload_link_to(upload)
    govuk_link_to(
      "#{upload.name} (opens in a new tab)",
      upload.url,
      target: :_blank,
      rel: :noopener,
    )
  end
end
