class EligibilityInterface::CountryForm
  include ActiveModel::Model

  attr_accessor :location, :eligibility_check

  validates :location, presence: true
  validates :eligibility_check, presence: true

  def save
    return false unless valid?

    eligibility_check.country_code = location.split(":")[1]
    eligibility_check.save!
  end
end
