# frozen_string_literal: true

class AssessorInterface::AssessmentConfirmationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :confirmation, :boolean

  validates :confirmation, inclusion: [true, false]
end
