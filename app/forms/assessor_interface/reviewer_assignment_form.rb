# frozen_string_literal: true

class AssessorInterface::ReviewerAssignmentForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :application_form, :staff
  attribute :reviewer_id, :string

  validates :application_form, :staff, presence: true
  validate :reviewer_not_assessor

  def save
    return false unless valid?

    AssignApplicationFormReviewer.call(
      application_form:,
      user: staff,
      reviewer:,
    )
  end

  private

  def reviewer
    reviewer_id.present? ? Staff.find(reviewer_id) : nil
  end

  def reviewer_not_assessor
    if (assessor = application_form&.assessor).present? && reviewer == assessor
      errors.add(:reviewer_id, :inclusion)
    end
  end
end
