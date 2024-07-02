# frozen_string_literal: true

class EligibilityInterface::DegreeForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :eligibility_check
  attribute :degree, :boolean

  validates :eligibility_check, presence: true
  validates :degree, inclusion: { in: [true, false] }

  def save
    return false unless valid?

    eligibility_check.update!(degree:)
  end
end
