# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# regenerate from production database with
#
# Country.all.to_h do |country|
#   [
#     country.code,
#     country.regions.filter_map do |region|
#       next if region.name.blank?
#       {
#         name: region.name,
#         status_check: region.status_check,
#         sanction_check: region.sanction_check,
#         application_form_enabled: region.application_form_enabled,
#         legacy: region.legacy
#       }
#     end
#   ]
# end

COUNTRIES = {
  "BE" => [
    {
      name: "Flemish region",
      status_check: "none",
      sanction_check: "none",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "French region",
      status_check: "none",
      sanction_check: "none",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "German region",
      status_check: "none",
      sanction_check: "none",
      application_form_enabled: false,
      legacy: true
    }
  ],
  "CZ" => [],
  "EE" => [],
  "FR" => [],
  "IS" => [],
  "LV" => [],
  "LI" => [],
  "LU" => [],
  "MT" => [],
  "SI" => [],
  "NZ" => [],
  "GI" => [],
  "GB-SCT" => [],
  "GB-NIR" => [],
  "AT" => [],
  "CH" => [],
  "GR" => [],
  "US" => [
    {
      name: "Kentucky",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "Mississippi",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "Maryland",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "Nevada",
      status_check: "online",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Iowa",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Massachusetts",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Michigan",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Missouri",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "New York",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "North Carolina",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Oklahoma",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Oregon",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Pennsylvania",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Tennessee",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Texas",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Utah",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Washington",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Washington DC",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Maine",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "Wyoming",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "North Dakota",
      status_check: "online",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "South Dakota",
      status_check: "online",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "Nebraska",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "New Mexico",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "Alabama",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "Hawaii",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Colorado",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Alaska",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Arkansas",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "California",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Delaware",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Florida",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Georgia",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Idaho",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Illinois",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Louisiana",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Indiana",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "Connecticut",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "West Virginia",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "Minnesota",
      status_check: "online",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "New Hampshire",
      status_check: "online",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "Rhode Island",
      status_check: "online",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "Vermont",
      status_check: "online",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "Virginia",
      status_check: "online",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "Wisconsin",
      status_check: "online",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "Arizona",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "Kansas",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "Montana",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "Ohio",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "South Carolina",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    },
    {
      name: "New Jersey",
      status_check: "online",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: true
    }
  ],
  "HU" => [],
  "DE" => [
    {
      name: "North Rhine-Westphalia",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Lower Saxony",
      status_check: "written",
      sanction_check: "none",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Baden-Wurttemberg",
      status_check: "written",
      sanction_check: "none",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Bremen",
      status_check: "written",
      sanction_check: "none",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Hessen",
      status_check: "written",
      sanction_check: "none",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Saxony-Anhalt",
      status_check: "written",
      sanction_check: "none",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Saarland",
      status_check: "written",
      sanction_check: "none",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Berlin",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Brandenburg",
      status_check: "written",
      sanction_check: "none",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Bavaria",
      status_check: "written",
      sanction_check: "none",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Schleswig-Holstein",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Hamburg",
      status_check: "written",
      sanction_check: "none",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Saxony",
      status_check: "written",
      sanction_check: "none",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Mecklenburg-Vorpommern",
      status_check: "written",
      sanction_check: "none",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Rhineland-Palatinate",
      status_check: "written",
      sanction_check: "none",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Thuringia",
      status_check: "written",
      sanction_check: "none",
      application_form_enabled: false,
      legacy: false
    }
  ],
  "HR" => [],
  "BG" => [],
  "NL" => [],
  "IT" => [],
  "PL" => [],
  "IE" => [],
  "ES" => [],
  "AU" => [
    {
      name: "New South Wales",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "South Australia",
      status_check: "online",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Australian Capital Territory",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Queensland",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Victoria",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Northern Territory",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Western Australia",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Tasmania",
      status_check: "online",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: false
    }
  ],
  "CA" => [
    {
      name: "Manitoba",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Newfoundland and Labrador",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "New Brunswick",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Northwest Territories",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Nova Scotia",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Prince Edward Island",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Quebec",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Alberta",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "British Columbia",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Ontario",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Saskatchewan",
      status_check: "online",
      sanction_check: "online",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Yukon",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: false
    },
    {
      name: "Nunavut",
      status_check: "written",
      sanction_check: "written",
      application_form_enabled: false,
      legacy: false
    }
  ],
  "LT" => [],
  "CY" => [],
  "RO" => [],
  "NO" => [],
  "SK" => [],
  "SE" => [],
  "PT" => [],
  "DK" => [],
  "FI" => []
}.freeze

COUNTRIES.each do |code, regions|
  country = Country.find_or_create_by!(code:)

  if regions.empty?
    country
      .regions
      .find_or_create_by!(name: "")
      .update!(legacy: false, application_form_enabled: true)
  else
    regions.each do |region|
      next if country.regions.where(name: region[:name]).any?

      country.regions.create!(region)
    end
  end
end
