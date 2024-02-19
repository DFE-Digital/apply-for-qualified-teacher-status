# frozen_string_literal: true

class AssessorInterface::ConsentMethodForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :qualification_request
  validates :qualification_request, presence: true

  attribute :consent_method
  validates :consent_method,
            presence: true,
            inclusion: %w[signed_ecctis signed_institution unsigned none]

  def save
    return false if invalid?
    qualification_request.update!(consent_method:)
    true
  end
end
