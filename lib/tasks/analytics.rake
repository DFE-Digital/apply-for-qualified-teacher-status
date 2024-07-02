# frozen_string_literal: true

require "csv"

namespace :analytics do
  desc "Generate a countries CSV file for analytics dashboards."
  task generate_countries_csv: :environment do
    CSV.open("countries.csv", "wb") do |csv|
      csv << %w[code name]
      Country::CODES.each { |code| csv << [code, CountryName.from_code(code)] }
    end
  end

  desc "Extract publication data."
  task :extract_publication, %i[from to] => :environment do |_task, args|
    from = Date.parse(args[:from])
    to = Date.parse(args[:to])

    records = Analytics::PublicationExtract.call(from:, to:)

    CSV.open(
      "publication-data-extract-#{from.iso8601}-#{to.iso8601}.csv",
      "wb",
    ) do |csv|
      csv << records.first.keys
      records.each { |record| csv << record.values }
    end
  end
end
