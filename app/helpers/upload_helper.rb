# frozen_string_literal: true

module UploadHelper
  def upload_link_to(upload)
    if upload.unsafe_to_link?
      tag.div(class: "govuk-form-group--error") do
        tag.p(upload.filename, class: "govuk-!-font-weight-bold") +
          tag.p(
            I18n.t("teacher_interface.documents.unsafe_to_link"),
            class: "govuk-error-message",
          )
      end
    elsif upload.safe_to_link?
      govuk_link_to(upload.filename, upload_path(upload), new_tab: true)
    else
      upload.filename
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
