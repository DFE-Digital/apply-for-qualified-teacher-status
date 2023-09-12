# == Schema Information
#
# Table name: countries
#
#  id                         :bigint           not null, primary key
#  code                       :string           not null
#  eligibility_enabled        :boolean          default(TRUE), not null
#  eligibility_skip_questions :boolean          default(FALSE), not null
#  other_information          :text             default(""), not null
#  qualifications_information :text             default(""), not null
#  sanction_information       :string           default(""), not null
#  status_information         :string           default(""), not null
#  subject_limited            :boolean          default(FALSE)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_countries_on_code  (code) UNIQUE
#
class Country < ApplicationRecord
  has_many :regions

  LOCATION_AUTOCOMPLETE_CANONICAL_LIST =
    JSON.parse(File.read("public/location-autocomplete-canonical-list.json"))

  CODES =
    LOCATION_AUTOCOMPLETE_CANONICAL_LIST.map do |row|
      CountryCode.from_location(row.last)
    end

  CODES_IN_EUROPEAN_ECONOMIC_AREA =
    YAML.load(File.read("lib/countries-in-european-economic-area.yaml"))

  validates :code, inclusion: { in: CODES }

  attribute :subject_limited, :boolean

  def eligibility_route
    if subject_limited
      "expanded"
    elsif eligibility_skip_questions
      "reduced"
    else
      "standard"
    end
  end

  def eligibility_route=(value)
    subject_limited_will_change!
    eligibility_skip_questions_will_change!
    if value == "standard"
      self.subject_limited = false 
      self.eligibility_skip_questions = false
    elsif value == "reduced"
      self.subject_limited = false 
      self.eligibility_skip_questions = true
    elsif value == "expanded"
      self.subject_limited = true 
      self.eligibility_skip_questions = false
    end
  end
end
