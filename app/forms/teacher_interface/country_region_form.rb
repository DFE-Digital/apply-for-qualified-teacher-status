# frozen_string_literal: true

module TeacherInterface
  class CountryRegionForm < BaseForm
    attr_accessor :teacher
    attribute :location, :string
    attribute :region_id, :integer

    validates :teacher, presence: true
    validates :location, presence: true
    validates :region_id, presence: true, if: -> { location.present? }

    def location=(value)
      super(value)
      self.region_id = regions.count == 1 ? regions.first.id : nil
    end

    def regions
      Region
        .joins(:country)
        .where(country: { code: country_code, eligibility_enabled: true })
        .order(:name)
    end

    def needs_region?
      location.present? && region_id.blank?
    end

    def update_model
      ApplicationFormFactory.call(teacher:, region: Region.find(region_id))
    end

    private

    def country_code
      CountryCode.from_location(location)
    end
  end
end
