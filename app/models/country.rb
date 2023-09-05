# == Schema Information
#
# Table name: countries
#
#  id                                    :bigint           not null, primary key
#  code                                  :string           not null
#  eligibility_enabled                   :boolean          default(TRUE), not null
#  eligibility_skip_questions            :boolean          default(FALSE), not null
#  other_information                     :text             default(""), not null
#  qualifications_information            :text             default(""), not null
#  sanction_information                  :string           default(""), not null
#  status_information                    :string           default(""), not null
#  teaching_authority_address            :text             default(""), not null
#  teaching_authority_certificate        :text             default(""), not null
#  teaching_authority_emails             :text             default([]), not null, is an Array
#  teaching_authority_name               :text             default(""), not null
#  teaching_authority_online_checker_url :string           default(""), not null
#  teaching_authority_websites           :text             default([]), not null, is an Array
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#
# Indexes
#
#  index_countries_on_code  (code) UNIQUE
#
class Country < ApplicationRecord
  include TeachingAuthorityContactable

  has_many :regions

  LOCATION_AUTOCOMPLETE_CANONICAL_LIST =
    JSON.parse(File.read("public/location-autocomplete-canonical-list.json"))

  CODES =
    LOCATION_AUTOCOMPLETE_CANONICAL_LIST.map do |row|
      CountryCode.from_location(row.last)
    end

  CODES_IN_EUROPEAN_ECONOMIC_AREA =
    YAML.load(File.read("lib/countries-in-european-economic-area.yaml"))

  CODES_ELIGIBLE_IN_FEBRUARY_2023 =
    YAML.load(File.read("lib/countries-eligible-in-february-2023.yaml"))

  CODES_REQUIRING_SECONDARY_EDUCATION_TEACHING_QUALIFICATION =
    CODES_ELIGIBLE_IN_FEBRUARY_2023 - %w[HK UA]

  validates :code, inclusion: { in: CODES }

  validates :teaching_authority_online_checker_url, url: { allow_blank: true }

  alias_method :country, :itself
end
