# frozen_string_literal: true

class SupportInterface::CountryForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :country
  validates :country, presence: true

  attribute :eligibility_enabled, :boolean
  attribute :eligibility_skip_questions, :boolean
  attribute :has_regions, :boolean
  attribute :other_information, :string
  attribute :qualifications_information, :string
  attribute :region_names, :string
  attribute :sanction_information, :string
  attribute :status_information, :string
  attribute :teaching_authority_address, :string
  attribute :teaching_authority_certificate, :string
  attribute :teaching_authority_emails_string, :string
  attribute :teaching_authority_name, :string
  attribute :teaching_authority_online_checker_url, :string
  attribute :teaching_authority_websites_string, :string

  validates :eligibility_enabled, inclusion: { in: [true, false] }
  validates :eligibility_skip_questions, inclusion: { in: [true, false] }
  validates :has_regions, inclusion: { in: [true, false] }
  validates :region_names, presence: true, if: :has_regions

  def save!
    ActiveRecord::Base.transaction do
      assign_country_attributes
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
      eligibility_skip_questions:,
      other_information:,
      qualifications_information:,
      sanction_information:,
      status_information:,
      teaching_authority_address:,
      teaching_authority_certificate:,
      teaching_authority_emails_string:,
      teaching_authority_name:,
      teaching_authority_online_checker_url:,
      teaching_authority_websites_string:,
    )
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
end
