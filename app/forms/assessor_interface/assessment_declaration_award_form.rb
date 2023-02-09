# frozen_string_literal: true

class AssessorInterface::AssessmentDeclarationAwardForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :declaration, :boolean

  validates :declaration, presence: true
end
