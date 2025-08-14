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
      DeprioritiseAssessment.call(assessment:, user:)
    end

    unassign_assessor

    true
  end

  private

  def unassign_assessor
    AssignApplicationFormAssessor.call(
      application_form: assessment.application_form,
      user:,
      assessor: nil,
    )
  end
end
