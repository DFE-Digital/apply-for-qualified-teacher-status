# frozen_string_literal: true

class SupportInterface::CountryForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Dirty

  attr_accessor :country
  validates :country, presence: true

  attribute :eligibility_enabled, :boolean
  attribute :eligibility_route, :string
  attribute :has_regions, :boolean
  attribute :other_information, :string
  attribute :region_names, :string
  attribute :sanction_information, :string
  attribute :status_information, :string
  attribute :teaching_qualification_information, :string

  validates :eligibility_enabled, inclusion: { in: [true, false] }
  validates :eligibility_route, inclusion: { in: %w[expanded reduced standard] }
  validates :has_regions, inclusion: { in: [true, false] }
  validates :region_names, presence: true, if: :has_regions

  def save!
    assign_country_attributes

    ActiveRecord::Base.transaction do
      country.save!

      diff_actions.each do |action|
        case action[:action]
        when :create
          @country.regions.create!(name: action[:name])
        when :delete
          region = @country.regions.find_by!(name: action[:name])
          region.eligibility_checks.delete_all
          region.destroy!
        end
      end
    end

    true
  end

  def assign_country_attributes
    country.assign_attributes(
      eligibility_enabled:,
      eligibility_skip_questions: eligibility_route == "reduced",
      subject_limited: eligibility_route == "expanded",
    )

    if has_regions
      country.assign_attributes(
        other_information:,
        sanction_information:,
        status_information:,
        teaching_qualification_information:,
      )
    else
      country.assign_attributes(
        other_information: "",
        sanction_information: "",
        status_information: "",
        teaching_qualification_information: "",
      )
    end
  end

  def diff_actions
    @diff_actions ||=
      begin
        current_region_names = country.regions.map(&:name)
        new_region_names =
          has_regions ? region_names.split("\n").map(&:chomp) : []

        new_region_names = [""] if new_region_names.empty?

        regions_to_delete = current_region_names - new_region_names
        regions_to_create = new_region_names - current_region_names

        delete_actions =
          regions_to_delete.map { |name| { action: :delete, name: } }
        create_actions =
          regions_to_create.map { |name| { action: :create, name: } }

        (delete_actions + create_actions).sort_by { |action| action[:name] }
      end
  end

  def self.for_existing_country(country)
    eligibility_route =
      if country.subject_limited
        "expanded"
      elsif country.eligibility_skip_questions
        "reduced"
      else
        "standard"
      end

    new(
      country:,
      eligibility_enabled: country.eligibility_enabled,
      eligibility_route:,
      has_regions: country.regions.count > 1,
      other_information: country.other_information,
      region_names: country.regions.pluck(:name).join("\n"),
      sanction_information: country.sanction_information,
      status_information: country.status_information,
      teaching_qualification_information:
        country.teaching_qualification_information,
    )
  end
end
