# frozen_string_literal: true

module TeacherInterface
  class DownloadUnsignedConsentDocumentForm < BaseForm
    attr_accessor :consent_request
    attribute :downloaded, :boolean

    validates :consent_request, presence: true
    validates :downloaded, presence: true

    def update_model
      consent_request.update!(unsigned_document_downloaded: true) if downloaded
    end
  end
end
