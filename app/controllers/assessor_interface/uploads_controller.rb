# frozen_string_literal: true

module AssessorInterface
  class UploadsController < BaseController
    include ActiveStorage::Streaming
    include HistoryTrackable
    include StreamedResponseAuthenticatable
    include RescueActiveStorageErrors
    include UploadHelper

    skip_before_action :authenticate_staff!
    before_action { authenticate_or_redirect(:staff) }

    def show
      authorize %i[assessor_interface application_form]

      if upload_downloadable?(upload)
        send_blob_stream(upload.attachment, disposition: :inline)
      else
        render "shared/malware_scan"
      end
    end

    private

    def upload
      @upload ||= document.uploads.find(params[:id])
    end

    def document
      @document ||= Document.find(params[:document_id])
    end
  end
end
