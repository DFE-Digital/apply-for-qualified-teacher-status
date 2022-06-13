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

  def success_url
    {
      eligible:
        Rails.application.routes.url_helpers.eligibility_interface_degree_path,
      ineligible:
        Rails
          .application
          .routes
          .url_helpers
          .eligibility_interface_ineligible_path,
      legacy:
        Rails
          .application
          .routes
          .url_helpers
          .eligibility_interface_eligible_path,
      region:
        Rails.application.routes.url_helpers.eligibility_interface_region_path
    }.fetch(eligibility_check.country_eligibility_status)
  end
end
