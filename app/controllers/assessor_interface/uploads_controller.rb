# frozen_string_literal: true

module AssessorInterface
  class UploadsController < BaseController
    include ActiveStorage::Streaming

    before_action :authorize_assessor

    def show
      send_blob_stream(upload.attachment, disposition: :inline)
    rescue ActiveStorage::FileNotFoundError
      render "errors/not_found", status: :not_found
    end

    private

    def upload
      @upload ||= Document.find(params[:document_id]).uploads.find(params[:id])
    end
  end
end
