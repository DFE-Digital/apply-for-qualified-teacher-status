namespace :countries do
  desc "Set up countries for the private beta (assumes the database has been seeded)"
  task private_beta: :environment do
    regions = [
      { country_code: :IE }, # Republic of Ireland
      { country_code: :PL }, # Poland
      { country_code: :US, name: "Hawaii" }, # USA (Hawaii)
      { country_code: :ES }, # Spain
      { country_code: :CA, name: "British Columbia" }, # Canada (British Columbia)
      { country_code: :CY } # Cyprus
    ]

    Region.where(legacy: false).update_all(legacy: true)

    regions.each do |region_attributes|
      country_code = region_attributes.fetch(:country_code)
      name = region_attributes.fetch(:name, "")

      region =
        Region.joins(:country).find_by!(country: { code: country_code }, name:)

      region.update!(legacy: false)
    end
  end
end
