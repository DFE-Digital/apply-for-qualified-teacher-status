# frozen_string_literal: true

class AssessorInterface::VerifyReferencesForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :assessment
  attribute :references_verified, :boolean
  validates :references_verified, inclusion: [true, false]

  delegate :application_form, to: :assessment

  def save
    return false if invalid?

    assessment.update!(references_verified:)

    true
  end
end
