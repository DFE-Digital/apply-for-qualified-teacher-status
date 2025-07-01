# frozen_string_literal: true

class AssessorInterface::AssessmentPrioritisationDecisionForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :assessment, :user

  validates :assessment, presence: true
  validates :user, presence: true

  attribute :passed, :boolean
  validates :passed, inclusion: [true, false]

  def save
    return false unless valid?

    if passed
      PrioritiseAssessment.call(assessment:, user:)
    else
      raise "Not Implemented"
    end

    true
  end
end
