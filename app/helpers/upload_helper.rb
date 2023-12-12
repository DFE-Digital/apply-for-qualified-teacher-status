module UploadHelper
  def upload_link_to(upload)
    if downloadable?(upload)
      govuk_link_to(
        "#{upload.name} (opens in a new tab)",
        [interface, :application_form, upload.document, upload],
        new_tab: true,
      )
    else
      output =
        govuk_link_to(
          upload.name,
          [interface, :application_form, upload.document, upload],
        )
      if show_scan_result_error?(upload)
        output +=
          tag.p(
            "There’s a problem with this file",
            class: "govuk-error-message",
          )
      end
      output
    end
  end

  def interface
    if request.path.start_with?("/assessor/")
      :assessor_interface
    else
      :teacher_interface
    end
  end

  def downloadable?(upload)
    unless FeatureFlags::FeatureFlag.active?(:fetch_malware_scan_result)
      return true
    end

    upload.scan_result_clean?
  end

  def show_scan_result_error?(upload)
    unless FeatureFlags::FeatureFlag.active?(:fetch_malware_scan_result)
      return false
    end

    upload.scan_result_error? || upload.scan_result_suspect?
  end
end
