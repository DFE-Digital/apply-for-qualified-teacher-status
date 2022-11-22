namespace :example_data do
  desc "Create example data for testing."
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

    staff_members = admins + assessors

    staff_members.each do |staff|
      FactoryBot.create(
        :staff,
        :confirmed,
        name: staff[:name],
        email: staff[:email],
        award_decline_permission:
          staff[:award_decline_permission] || false,
        support_console_permission:
          staff[:support_console_permission] || false,
      )
    end

    Country.all.each do |country|
      country.regions.each do |region|
        application_form_traits_for(region).each do |traits|
          teacher = FactoryBot.create(:teacher, :confirmed)
          application_form =
            FactoryBot.create(:application_form, *traits, teacher:, region:)
          assessment = AssessmentFactory.call(application_form:)

          next unless application_form.further_information_requested?

          FactoryBot.create(
            :further_information_request,
            :requested,
            :with_items,
            assessment:,
          )
        end
      end
    end
  end

  desc "Reset database suitable for generating example data."
  task reset: :environment do
    if HostingEnvironment.production?
      raise "THIS TASK CANNOT BE RUN IN PRODUCTION"
    end

    TimelineEvent.delete_all
    AssessmentSection.delete_all
    Assessment.delete_all
    Qualification.delete_all
    WorkHistory.delete_all
    Note.delete_all
    ApplicationForm.delete_all
    Teacher.delete_all
    Staff.delete_all
  end

  desc "Reset and regenerate example data."
  task regenerate: %i[reset generate]
end

def assessors
  [
    {
      name: "Dave Assessor",
      email: "assessor-dave@example.com",
      support_console_permission: false,
      award_decline_permission: true,
    },
    {
      name: "Beryl Assessor",
      email: "assessor-beryl@example.com",
      support_console_permission: false,
      award_decline_permission: true,
    },
  ]
end

def admins
  [{
    name: "Sally Admin",
    email: "admin-sally@example.com",
    support_console_permission: true,
    award_decline_permission: false,
  }]
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
    %i[with_personal_information with_alternative_name],
    %i[
      with_personal_information
      with_alternative_name
      with_name_change_document
    ],
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
    ] + evidential_traits << :submitted,
    %i[
      with_personal_information
      with_alternative_name
      with_name_change_document
      with_completed_qualification
      with_identification_document
      with_age_range
      with_subjects
    ] + evidential_traits << :submitted,
    %i[
      with_personal_information
      with_completed_qualification
      with_identification_document
      with_age_range
      with_subjects
    ] + evidential_traits << :submitted << :further_information_requested,
    %i[
      with_personal_information
      with_alternative_name
      with_name_change_document
      with_completed_qualification
      with_identification_document
      with_age_range
      with_subjects
    ] + evidential_traits << :submitted << :further_information_requested,
  ]
end
