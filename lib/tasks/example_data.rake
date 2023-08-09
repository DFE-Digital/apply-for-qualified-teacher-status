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

    staff_members.each do |staff|
      FactoryBot.create(:staff, :confirmed, **staff)
    end

    create_application_forms(new_regs: false)
    create_application_forms(new_regs: true)
  end

  desc "Reset database suitable for generating example data."
  task reset: :environment do
    if HostingEnvironment.production?
      raise "THIS TASK CANNOT BE RUN IN PRODUCTION"
    end

    TimelineEvent.delete_all
    DQTTRNRequest.delete_all
    ReminderEmail.delete_all
    FurtherInformationRequest.delete_all
    ProfessionalStandingRequest.delete_all
    QualificationRequest.delete_all
    ReferenceRequest.delete_all
    SelectedFailureReason.delete_all
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

def staff_members
  [
    {
      name: "Dave Assessor",
      email: "assessor-dave@example.com",
      award_decline_permission: true,
      manage_applications_permission: false,
      reverse_decision_permission: false,
      support_console_permission: false,
    },
    {
      name: "Beryl Assessor",
      email: "assessor-beryl@example.com",
      award_decline_permission: true,
      manage_applications_permission: false,
      reverse_decision_permission: false,
      support_console_permission: false,
    },
    {
      name: "Sally Manager",
      email: "manager-sally@example.com",
      award_decline_permission: false,
      manage_applications_permission: true,
      reverse_decision_permission: true,
      support_console_permission: true,
    },
    {
      name: "Antonio Helpdesk",
      email: "helpdesk-antonio@example.com",
      award_decline_permission: false,
      manage_applications_permission: false,
      reverse_decision_permission: false,
      support_console_permission: false,
    },
  ]
end

def evidential_traits_for(region, new_regs)
  checks = [region.status_check, region.sanction_check]

  [].tap do |traits|
    if (checks.include?("none") || new_regs) &&
         !region.application_form_skip_work_history
      traits << :with_work_history
    end
    traits << :with_written_statement if checks.include?("written")
    traits << :with_registration_number if checks.include?("online")
  end
end

def english_language_trait
  %i[
    with_english_language_medium_of_instruction
    with_english_language_provider
    with_english_language_exemption_by_citizenship
    with_english_language_exemption_by_qualification
  ].sample
end

def application_form_traits_for(region, new_regs)
  evidential_traits = evidential_traits_for(region, new_regs)
  additional_traits = evidential_traits + [english_language_trait]

  [
    [],
    %i[
      with_personal_information
      with_completed_qualification
      with_identification_document
      with_age_range
      with_subjects
    ] + additional_traits,
    %i[
      with_personal_information
      with_completed_qualification
      with_identification_document
      with_age_range
      with_subjects
      submitted
    ] + additional_traits,
    %i[
      with_personal_information
      with_completed_qualification
      with_identification_document
      with_age_range
      with_subjects
      submitted
      preliminary_check
    ] + additional_traits,
    %i[
      with_personal_information
      with_completed_qualification
      with_identification_document
      with_age_range
      with_subjects
      submitted
      waiting_on
    ] + additional_traits,
  ]
end

def create_application_forms(new_regs:)
  new_regs_date = Date.parse(ENV.fetch("NEW_REGS_DATE", "2023-02-01"))
  old_regs_date = new_regs_date - 1.day

  Region.all.each do |region|
    application_form_traits_for(region, new_regs).each do |traits|
      created_at = new_regs ? new_regs_date : old_regs_date
      traits.insert(0, :new_regs) if new_regs

      application_form =
        FactoryBot.create(:application_form, *traits, region:, created_at:)

      next if application_form.draft?

      assessment = AssessmentFactory.call(application_form:)

      if application_form.teaching_authority_provides_written_statement
        FactoryBot.create(
          :professional_standing_request,
          :requested,
          assessment:,
        )
        application_form.update!(waiting_on_professional_standing: true)
      elsif application_form.waiting_on?
        if application_form.needs_written_statement && rand(2).zero?
          FactoryBot.create(
            :professional_standing_request,
            :requested,
            assessment:,
          )
          application_form.update!(waiting_on_professional_standing: true)
        else
          FactoryBot.create(
            :further_information_request,
            :requested,
            :with_items,
            assessment:,
          )
          application_form.update!(waiting_on_further_information: true)
        end
      elsif (work_history = application_form.work_histories.first) &&
            rand(2).zero?
        reference_request_trait = ReferenceRequest.states.keys.sample
        FactoryBot.create(
          :reference_request,
          reference_request_trait,
          assessment:,
          work_history:,
        )
        application_form.update!(waiting_on_reference: true)
      end
    end
  end
end
