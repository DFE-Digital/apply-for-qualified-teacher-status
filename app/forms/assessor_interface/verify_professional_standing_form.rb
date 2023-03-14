# frozen_string_literal: true

class AssessorInterface::VerifyProfessionalStandingForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :verify_professional_standing, :boolean
  validates :verify_professional_standing, inclusion: [true, false]
end
