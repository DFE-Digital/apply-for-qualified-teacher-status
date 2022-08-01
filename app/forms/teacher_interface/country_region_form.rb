class TeacherInterface::CountryRegionForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :application_form

  attribute :location, :string
  attribute :region_id, :integer

  validates :application_form, presence: true
  validates :location, presence: true
  validates :region_id, presence: true, if: -> { location.present? }

  def location=(value)
    super(value)
    self.region_id = regions.count == 1 ? regions.first.id : nil
  end

  def regions
    Region.joins(:country).where(country: { code: country_code }).order(:name)
  end

  def needs_region?
    location.present? && region_id.blank?
  end

  def save
    return false unless valid?

    application_form.region_id = region_id
    application_form.save!
  end

  private

  def country_code
    location.split(":")[1]
  rescue StandardError
    nil
  end
end
