# frozen_string_literal: true

class SupportInterface::NewCountryForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :location, :string
  attribute :eligibility_route, :string
  attribute :has_regions, :boolean
  attribute :region_names, :string

  validates :location, presence: true
  validate :location_must_be_valid_country, if: -> { location.present? }
  validate :country_must_not_already_exist, if: -> { location.present? }
  validates :eligibility_route, inclusion: { in: %w[expanded reduced standard] }
  validates :has_regions, inclusion: { in: [true, false] }
  validates :region_names, presence: true, if: :has_regions

  def save
    return false if invalid?

    country =
      Country.new(
        code: country_code,
        eligibility_enabled: false,
        eligibility_skip_questions: eligibility_route == "reduced",
        subject_limited: eligibility_route == "expanded",
      )

    ActiveRecord::Base.transaction do
      country.save!

      if has_regions
        region_names
          .split("\n")
          .map(&:chomp)
          .reject(&:empty?)
          .each { |name| country.regions.create!(name:) }
      else
        country.regions.create!(name: "")
      end
    end

    country
  end

  def country_code
    CountryCode.from_location(location)
  end

  private

  def location_must_be_valid_country
    errors.add(:location, :invalid) unless Country::CODES.include?(country_code)
  end

  def country_must_not_already_exist
    if Country.exists?(code: country_code)
      errors.add(:location, :already_exists)
    end
  end
end
