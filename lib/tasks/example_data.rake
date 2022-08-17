require_relative Rails.root.join("config/environment")
require "factory_bot"

namespace :example_data do
  desc "Create example data for testing"
  task generate: :environment do
    raise "THIS TASK CANNOT BE RUN IN PRODUCTION" if Rails.env.production?

    if Teacher.any?
      puts "Noop as DB already contains data"
      exit
    end

    Teacher.reset_column_information
    Faker::Config.locale = "en-GB"
    Faker::UniqueGenerator.clear
    FactoryBot.find_definitions

    Country.all.each do |country|
      country.regions.each do |region|
        application_form_traits_for(region).each do |traits|
          teacher = FactoryBot.create(:teacher)
          FactoryBot.create(:application_form, *traits, teacher:, region:)
        end
      end
    end
  end
end

def evidential_traits_for(status_check, sanction_check)
  args = [status_check, sanction_check]

  traits = {
    %w[none none] => [:with_work_history],
    %w[online none] => %i[with_reference_number with_work_history],
    %w[written none] => [:with_written_statement],
    %w[online written] => %i[with_written_statement with_reference_number],
    %w[written written] => [:with_written_statement],
    %w[online online] => [:with_reference_number]
  }

  raise "unknown evidence combination for #{args}" if traits[args].nil?

  traits[args]
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
