# frozen_string_literal: true

class AssessorInterface::VerifyQualificationsForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :verify_qualifications, :boolean
  validates :verify_qualifications, inclusion: [true, false]
end
