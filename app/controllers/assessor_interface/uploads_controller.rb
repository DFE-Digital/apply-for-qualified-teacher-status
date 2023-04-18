# frozen_string_literal: true

module AssessorInterface
  class UploadsController < BaseController
    include ActiveStorage::Streaming
    include StreamedResponseAuthenticatable
    include RescueActiveStorageErrors

    skip_before_action :authenticate_staff!, only: :show
    before_action -> { authenticate_or_redirect(:staff) }, only: :show

    before_action :authorize_assessor

    def show
      send_blob_stream(upload.attachment, disposition: :inline)
    end

    private

    def upload
      @upload ||= Document.find(params[:document_id]).uploads.find(params[:id])
    end
  end
end
