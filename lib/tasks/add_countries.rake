namespace :add_countries do
  desc "Add countries to support interface"
  task create_feb_1: :environment do
    countries.each do |country_hash|
      code = country_hash[:code]
      regions = country_hash[:regions]
      country = Country.find_or_create_by!(code:, eligibility_enabled: false)

      if regions.blank?
        country
          .regions
          .find_or_create_by!(name: "")
          .update!(legacy: false, application_form_enabled: false)
      else
        regions.each do |region|
          next if country.regions.where(name: region[:name]).any?

          country.regions.create!(
            legacy: false,
            application_form_enabled: false,
            **region,
          )
        end
      end
    end
  end
end

def countries
  [
    { code: "GH" },
    { code: "HK" },
    { code: "IN" },
    { code: "JM" },
    { code: "NG" },
    { code: "SG" },
    { code: "ZA" },
    { code: "UA" },
    { code: "ZW" },
  ]
end
