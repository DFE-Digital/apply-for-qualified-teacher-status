# frozen_string_literal: true

module DocumentHelper
  include UploadHelper

  def document_link_to(document, translated: false)
    if document.optional? && !document.available
      tag.em(
        "The applicant has indicated that they haven't " \
          "done an induction period and don't have this document.",
      )
    else
      uploads =
        (
          if translated
            document.translated_uploads
          else
            document.original_uploads
          end
        )

      tag.ul(class: "govuk-list") do
        uploads
          .order(:created_at)
          .each { |upload| concat(tag.li(upload_link_to(upload))) }
      end
    end
  end
end
