# frozen_string_literal: true

class EligibilityInterface::TeachChildrenForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :eligibility_check
  attribute :teach_children, :boolean

  validates :eligibility_check, presence: true
  validates :teach_children, inclusion: { in: [true, false] }

  def save
    return false unless valid?

    eligibility_check.update!(teach_children:)
  end
end
