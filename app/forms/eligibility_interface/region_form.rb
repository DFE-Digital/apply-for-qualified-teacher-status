class EligibilityInterface::RegionForm
  include ActiveModel::Model

  attr_accessor :eligibility_check
  attr_reader :region_id

  validates :eligibility_check, presence: true
  validates :region_id, presence: true

  def region_id=(value)
    @region_id = ActiveModel::Type::Integer.new.cast(value)
  end

  def save
    return false unless valid?

    eligibility_check.region_id = region_id
    eligibility_check.save!
  end

  def success_url
    {
      eligible:
        Rails
          .application
          .routes
          .url_helpers
          .eligibility_interface_qualifications_path,
      legacy:
        Rails.application.routes.url_helpers.eligibility_interface_eligible_path
    }.fetch(eligibility_check.region_eligibility_status)
  end
end
