# frozen_string_literal: true

class EligibilityInterface::CountryForm
  include ActiveModel::Model

  attr_accessor :location, :eligibility_check

  validates :location, presence: true
  validates :eligibility_check, presence: true

  def save
    return false unless valid?

    eligibility_check.update!(country_code: CountryCode.from_location(location))
  end
end
