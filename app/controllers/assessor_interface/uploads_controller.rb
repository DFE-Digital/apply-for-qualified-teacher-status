# frozen_string_literal: true

module AssessorInterface
  class UploadsController < BaseController
    include ActiveStorage::Streaming

    def show
      send_blob_stream(upload.attachment, disposition: :inline)
    end

    private

    def upload
      @upload ||= Document.find(params[:document_id]).uploads.find(params[:id])
    end
  end
end