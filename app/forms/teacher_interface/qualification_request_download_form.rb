# frozen_string_literal: true

module TeacherInterface
  class QualificationRequestDownloadForm < BaseForm
    attr_accessor :qualification_request
    attribute :downloaded, :boolean

    validates :qualification_request, presence: true
    validates :downloaded, presence: true

    def update_model
      if downloaded
        qualification_request.update!(
          unsigned_consent_document_downloaded: true,
        )
      end
    end
  end
end
