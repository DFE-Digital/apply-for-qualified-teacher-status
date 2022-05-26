class CountryForm
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
    if eligibility_check.country&.legacy
      "https://teacherservices.education.gov.uk/MutualRecognition/"
    elsif eligibility_check.country
      Rails.application.routes.url_helpers.teacher_interface_degree_path
    else
      Rails.application.routes.url_helpers.teacher_interface_ineligible_path
    end
  end
end
