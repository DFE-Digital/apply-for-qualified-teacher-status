namespace :example_data do
  desc "Create example data for testing"
  task generate: :environment do
    if HostingEnvironment.production?
      raise "THIS TASK CANNOT BE RUN IN PRODUCTION"
    end

    if Teacher.any?
      puts "Noop as DB already contains data"
      exit
    end

    Teacher.reset_column_information
    Faker::Config.locale = "en-GB"
    Faker::UniqueGenerator.clear

    Country.all.each do |country|
      country.regions.each do |region|
        application_form_traits_for(region).each do |traits|
          teacher = FactoryBot.create(:teacher, :confirmed)
          FactoryBot.create(:application_form, *traits, teacher:, region:)
        end
      end
    end
  end
end

def evidential_traits_for(status_check, sanction_check)
  args = [status_check, sanction_check]

  [].tap do |traits|
    traits << :with_work_history if args.include?("none")
    traits << :with_written_statement if args.include?("written")
    traits << :with_registration_number if args.include?("online")
  end
end

def application_form_traits_for(region)
  evidential_traits =
    evidential_traits_for(region.status_check, region.sanction_check)

  [
    [],
    [:with_personal_information],
    %i[with_personal_information with_completed_qualification],
    %i[
      with_personal_information
      with_completed_qualification
      with_identification_document
    ],
    %i[
      with_personal_information
      with_completed_qualification
      with_identification_document
      with_age_range
    ],
    %i[
      with_personal_information
      with_completed_qualification
      with_identification_document
      with_age_range
      with_subjects
    ],
    %i[
      with_personal_information
      with_completed_qualification
      with_identification_document
      with_age_range
      with_subjects
    ] + evidential_traits,
    %i[
      with_personal_information
      with_completed_qualification
      with_identification_document
      with_age_range
      with_subjects
    ] + evidential_traits << :submitted
  ]
end
