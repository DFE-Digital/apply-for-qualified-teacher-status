class CountryForm
  include ActiveModel::Model

  attr_accessor :country_code, :eligibility_check

  validates :country_code, presence: true
  validates :eligibility_check, presence: true

  def save
    return false unless valid?

    eligibility_check.country_code = country_code
    eligibility_check.save!
  end

  def eligible?
    eligibility_check.country_code != "INELIGIBLE"
  end

  def success_url
    unless eligible?
      return(
        Rails.application.routes.url_helpers.teacher_interface_ineligible_path
      )
    end

    Rails.application.routes.url_helpers.teacher_interface_degree_path
  end
end
