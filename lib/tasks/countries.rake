namespace :countries do
  desc "Set up countries for the private beta (assumes the database has been seeded)"
  task private_beta: :environment do
    ConfigureCountries.private_beta!
  end
end
