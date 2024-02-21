# frozen_string_literal: true

class AssessorInterface::UploadUnsignedConsentDocumentForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include UploadableForm

  attr_accessor :qualification_request
  validates :qualification_request, presence: true

  def save
    return false if invalid?

    ActiveRecord::Base.transaction { create_uploads! }

    true
  end

  def document
    qualification_request&.unsigned_consent_document
  end
end
