require "csv"

namespace :analytics do
  desc "Generate a countries CSV file for analytics dashboards."
  task generate_countries_csv: :environment do
    CSV.open("countries.csv", "wb") do |csv|
      csv << %w[code name]
      Country::CODES.each { |code| csv << [code, CountryName.from_code(code)] }
    end
  end
end
