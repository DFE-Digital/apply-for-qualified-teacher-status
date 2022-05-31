# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

COUNTRIES = {
  AT: {
  },
  BE: {
    regions: ["Flemish region", "French region", "German region"]
  },
  BG: {
  },
  HR: {
  },
  CY: {
  },
  CZ: {
  },
  DK: {
  },
  EE: {
  },
  FI: {
  },
  FR: {
  },
  DE: {
    regions: [
      "Baden-Wurttemberg",
      "Bavaria",
      "Berlin",
      "Brandenburg",
      "Bremen",
      "Hamburg",
      "Hessen",
      "Lower Saxony",
      "Mecklenburg-Vorpommern",
      "Saxony-Anhalt",
      "Schleswig-Holstein",
      "Thuringia",
      "North Rhine-Westphalia",
      "Saxony",
      "Rhineland-Palatinate",
      "Saarland"
    ]
  },
  GR: {
  },
  HU: {
  },
  IS: {
  },
  IT: {
  },
  LV: {
  },
  LI: {
  },
  LT: {
  },
  LU: {
  },
  MT: {
  },
  NL: {
  },
  NO: {
  },
  PL: {
  },
  PT: {
  },
  IE: {
  },
  RO: {
  },
  SK: {
  },
  SI: {
  },
  ES: {
  },
  SE: {
  },
  CH: {
  },
  AU: {
    regions: [
      "Victoria",
      "Queensland",
      "Northern Territory",
      "Western Australia",
      "Tasmania",
      "New South Wales",
      "South Australia",
      "Australian Capital Territory"
    ]
  },
  CA: {
    regions: [
      "Ontario",
      "Alberta",
      "British Columbia",
      "Manitoba",
      "Nunavut",
      "New Brunswick",
      "Newfoundland and Labrador",
      "Northwest Territories",
      "Nova Scotia",
      "Prince Edward Island",
      "Quebec",
      "Saskatchewan",
      "Yukon"
    ]
  },
  NZ: {
  },
  US: {
    regions: [
      "Alabama",
      "Alaska",
      "Arizona",
      "Arkansas",
      "California",
      "Colorado",
      "Connecticut",
      "Delaware",
      "Florida",
      "Georgia",
      "Hawaii",
      "Idaho",
      "Illinois",
      "Indiana",
      "Kentucky",
      "Kansas",
      "Louisiana",
      "Maine",
      "Iowa",
      "Maryland",
      "Massachusetts",
      "Montana",
      "Michigan",
      "Minnesota",
      "Mississippi",
      "Missouri",
      "Nebraska",
      "Nevada",
      "New Hampshire",
      "New Jersey",
      "New Mexico",
      "New York",
      "North Carolina",
      "North Dakota",
      "Ohio",
      "Oklahoma",
      "Oregon",
      "Pennsylvania",
      "Rhode Island",
      "South Carolina",
      "Tennessee",
      "Texas",
      "Utah",
      "Vermont",
      "Virginia",
      "Washington",
      "Washington DC",
      "West Virginia",
      "Wisonsin",
      "Wyoming"
    ]
  },
  GI: {
  },
  "GB-SCT": {
  },
  "GB-NIR": {
  }
}.freeze

COUNTRIES.each do |code, attributes|
  legacy = attributes.fetch(:legacy, false)
  regions = attributes.fetch(:regions, [])

  country = Country.create!(code:, legacy:)

  if regions.empty?
    country.regions.create!
  else
    regions.each { |name| country.regions.create!(name:) }
  end
end
