# frozen_string_literal: true

module UploadHelper
  def upload_link_to(upload)
    href =
      govuk_link_to(
        "#{upload.name} (opens in a new tab)",
        upload_path(upload),
        target: :_blank,
        rel: :noopener,
      )

    scan_result_problem =
      malware_scanning_enabled? &&
        (upload.scan_result_error? || upload.scan_result_suspect?)

    return href unless scan_result_problem

    href +
      tag.p("There’s a problem with this file", class: "govuk-error-message")
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

  def upload_downloadable?(upload)
    !malware_scanning_enabled? || upload.scan_result_clean?
  end

  def malware_scanning_enabled?
    FeatureFlags::FeatureFlag.active?(:fetch_malware_scan_result)
  end
end
