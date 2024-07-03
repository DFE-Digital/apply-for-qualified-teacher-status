# frozen_string_literal: true

class EligibilityInterface::RegionForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :eligibility_check
  attribute :region_id, :integer

  validates :eligibility_check, presence: true
  validates :region_id, presence: true

  def save
    return false unless valid?

    eligibility_check.update!(region_id:)
  end
end
