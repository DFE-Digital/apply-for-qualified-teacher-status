# frozen_string_literal: true

class EligibilityInterface::QualifiedForSubjectForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :eligibility_check
  attribute :qualified_for_subject, :boolean

  validates :eligibility_check, presence: true
  validates :qualified_for_subject, inclusion: { in: [true, false] }

  def save
    return false unless valid?

    eligibility_check.update!(qualified_for_subject:)
  end
end
