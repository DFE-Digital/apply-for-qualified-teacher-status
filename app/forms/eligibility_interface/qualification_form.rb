# frozen_string_literal: true

class EligibilityInterface::QualificationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :eligibility_check
  attribute :qualification, :boolean

  validates :eligibility_check, presence: true
  validates :qualification, inclusion: { in: [true, false] }

  def save
    return false unless valid?

    eligibility_check.update!(qualification:)
  end
end
