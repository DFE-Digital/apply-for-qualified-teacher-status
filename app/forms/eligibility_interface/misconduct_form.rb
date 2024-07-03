# frozen_string_literal: true

class EligibilityInterface::MisconductForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :eligibility_check
  attribute :misconduct, :boolean

  validates :eligibility_check, presence: true
  validates :misconduct, inclusion: { in: [true, false] }

  def save
    return false unless valid?

    eligibility_check.update!(free_of_sanctions: !misconduct)
  end
end
