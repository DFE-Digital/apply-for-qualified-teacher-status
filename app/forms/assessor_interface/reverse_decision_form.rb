# frozen_string_literal: true

class AssessorInterface::ReverseDecisionForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :reverse, :boolean
  validates :reverse, inclusion: [true, false]
end
