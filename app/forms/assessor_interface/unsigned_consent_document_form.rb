# frozen_string_literal: true

class AssessorInterface::UnsignedConsentDocumentForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :assessment
  validates :assessment, presence: true

  attribute :generated, :boolean
  validates :generated, presence: true

  def save
    return false if invalid?

    assessment.update!(unsigned_consent_document_generated: true) if generated

    true
  end
end
