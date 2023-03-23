# frozen_string_literal: true

class AssessorInterface::AssessorAssignmentForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :application_form, :staff
  attribute :assessor_id, :string

  validates :application_form, :staff, presence: true
  validate :assessor_not_reviewer

  def save
    return false unless valid?

    AssignApplicationFormAssessor.call(
      application_form:,
      user: staff,
      assessor:,
    )
  end

  private

  def assessor
    assessor_id.present? ? Staff.find(assessor_id) : nil
  end

  def assessor_not_reviewer
    if (reviewer = application_form&.reviewer).present? && assessor == reviewer
      errors.add(:assessor_id, :inclusion)
    end
  end
end
