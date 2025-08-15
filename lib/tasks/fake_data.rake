# frozen_string_literal: true

namespace :fake_data do
  desc "Generate fake staff and teachers."
  task generate: :environment do
    if HostingEnvironment.production?
      raise "This task cannot be run in production."
    end

    if Staff.any? || Teacher.any?
      puts "Database already contains staff and teachers."
      exit
    end

    Faker::Config.locale = "en-GB"
    Faker::UniqueGenerator.clear

    FakeData::StaffGenerator.call

    DeliverEmail.pause

    countries = Country.includes(:regions)
    count = countries.count

    countries.each_with_index do |country, index|
      region = country.regions.sample

      puts "#{index + 1}/#{count} - Generating applications for #{CountryName.from_country(country)}"

      application_form_params_for_region(region).each do |params|
        FakeData::ApplicationFormGenerator.call(region:, params:)
      end
    end

    UpdateWorkingDaysJob.new.perform
    DeliverEmail.continue
  end

  desc "Reset database in preparation for generating fake data."
  task reset: :environment do
    if HostingEnvironment.production?
      raise "This task cannot be run in production."
    end

    TimelineEvent.delete_all
    TRSTRNRequest.delete_all
    ReminderEmail.delete_all
    ConsentRequest.delete_all
    FurtherInformationRequestItem.delete_all
    FurtherInformationRequest.delete_all
    ProfessionalStandingRequest.delete_all
    QualificationRequest.delete_all
    ReferenceRequest.delete_all
    SelectedFailureReason.delete_all
    AssessmentSection.delete_all
    PrioritisationReferenceRequest.delete_all
    PrioritisationWorkHistoryCheck.delete_all
    Assessment.delete_all
    Qualification.delete_all
    WorkHistory.delete_all
    Note.delete_all
    ApplicationForm.delete_all
    Teacher.delete_all
    Staff.delete_all
  end

  desc "Reset and regenerate fake data."
  task regenerate: %i[reset generate]
end

def application_form_params_for_region(region)
  params = [{}, { submitted: true }]

  if region.requires_preliminary_check ||
       region.teaching_authority_provides_written_statement
    params += [
      { pre_assessment: true },
      { pre_assessment: true, declined: true },
      { pre_assessment: true, received: true },
    ]
  end

  unless region.application_form_skip_work_history
    params += [{ prioritisation_check: true }]
  end

  if rand(5).zero?
    params += [
      { further_information: true },
      { further_information: true, received: true },
      { further_information: true, declined: true },
      { further_information: true, received: true, declined: true },
    ]
  end

  params += [
    { assessment: true },
    { assessment: true, declined: true },
    { verification: true },
    { verification: true, requested: true },
    { verification: true, received: true },
  ]

  params << { verification: true, expired: true } if rand(10).zero?

  if rand(20).zero?
    params << { verification: true, received: true, expired: true }
  end

  params << { verification: true, declined: true }

  params << { review: true } # if rand(10).zero?

  params + [{ review: rand(20).zero?, awarded: true }]
end
