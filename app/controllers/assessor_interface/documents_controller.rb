# frozen_string_literal: true

module AssessorInterface
  class DocumentsController < BaseController
    include ActiveStorage::Streaming
    include StreamedResponseAuthenticatable
    include RescueActiveStorageErrors
    include UploadHelper

    skip_before_action :authenticate_staff!
    before_action { authenticate_or_redirect(:staff) }

    def show_pdf
      authorize %i[assessor_interface application_form]

      unless document.downloadable?
        render "shared/malware_scan"
        return
      end

      translation = params[:scope] == "translated"

      if (pdf_data = ConvertToPDF.call(document:, translation:))
        send_data(pdf_data, type: "application/pdf", disposition: :inline)
      else
        error_internal_server_error
      end
    end

    private

    def document
      @document ||= Document.find(params[:id])
    end
  end
end
