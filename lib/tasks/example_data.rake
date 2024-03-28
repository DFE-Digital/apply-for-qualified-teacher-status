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

    create_application_forms
  end

  desc "Reset database suitable for generating example data."
  task reset: :environment do
    if HostingEnvironment.production?
      raise "THIS TASK CANNOT BE RUN IN PRODUCTION"
    end

    TimelineEvent.delete_all
    DQTTRNRequest.delete_all
    ReminderEmail.delete_all
    ConsentRequest.delete_all
    FurtherInformationRequestItem.delete_all
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
      assess_permission: true,
      change_email_permission: true,
      change_name_permission: false,
      change_work_history_permission: false,
      reverse_decision_permission: false,
      support_console_permission: false,
      verify_permission: false,
      withdraw_permission: false,
    },
    {
      name: "Beryl Assessor",
      email: "assessor-beryl@example.com",
      assess_permission: true,
      change_email_permission: true,
      change_name_permission: false,
      change_work_history_permission: false,
      reverse_decision_permission: false,
      support_console_permission: false,
      verify_permission: false,
      withdraw_permission: false,
    },
    {
      name: "Sally Manager",
      email: "manager-sally@example.com",
      assess_permission: false,
      change_email_permission: true,
      change_name_permission: true,
      change_work_history_permission: true,
      reverse_decision_permission: true,
      support_console_permission: true,
      verify_permission: false,
      withdraw_permission: true,
    },
    {
      name: "Antonio Helpdesk",
      email: "helpdesk-antonio@example.com",
      assess_permission: false,
      change_email_permission: true,
      change_name_permission: false,
      change_work_history_permission: false,
      reverse_decision_permission: false,
      support_console_permission: false,
      verify_permission: false,
      withdraw_permission: false,
    },
    {
      name: "Jeff Admin",
      email: "jeff-admin@example.com",
      assess_permission: false,
      change_email_permission: true,
      change_name_permission: false,
      change_work_history_permission: false,
      reverse_decision_permission: false,
      support_console_permission: false,
      verify_permission: true,
      withdraw_permission: false,
    },
  ]
end

def evidential_traits_for(region)
  checks = [region.status_check, region.sanction_check]

  [].tap do |traits|
    unless region.application_form_skip_work_history
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

def application_form_traits_for(region)
  evidential_traits = evidential_traits_for(region)

  traits =
    %i[
      with_personal_information
      with_degree_qualification
      with_identification_document
      with_age_range
      with_subjects
    ] + evidential_traits + [english_language_trait]

  [
    [],
    traits,
    traits + %i[submitted],
    (traits + %i[preliminary_check] if region.requires_preliminary_check),
    traits + %i[submitted action_required_by_external],
    traits + %i[submitted action_required_by_admin],
    traits + %i[awarded],
    traits + %i[declined],
  ].compact
end

def create_requestables(application_form, assessment, state)
  unless application_form.teaching_authority_provides_written_statement
    assessment.sections.update_all(passed: true)
  end

  if application_form.teaching_authority_provides_written_statement ||
       (
         application_form.needs_written_statement && state != :received &&
           rand(4).zero?
       )
    FactoryBot.create(:professional_standing_request, state, assessment:)

    unless application_form.teaching_authority_provides_written_statement
      assessment.verify!
    end
  elsif (work_histories = application_form.work_histories).present? &&
        rand(3).zero?
    work_histories.each do |work_history|
      FactoryBot.create(:reference_request, state, assessment:, work_history:)
    end

    assessment.verify!
  elsif (qualifications = application_form.qualifications).present? &&
        rand(2).zero?
    qualifications.each do |qualification|
      qualification_request =
        FactoryBot.create(
          :qualification_request,
          :with_consent_method,
          state,
          assessment:,
          qualification:,
        )

      if qualification_request.consent_method_signed?
        FactoryBot.create(:consent_request, state, assessment:, qualification:)
      end
    end

    assessment.verify!
  elsif state != :expired
    FactoryBot.create(
      :further_information_request,
      state,
      :with_items,
      assessment:,
    )
    assessment.request_further_information!
  end

  ApplicationFormStatusUpdater.call(
    application_form:,
    user: "Example data generator",
  )
end

def create_application_forms
  Region.all.find_each do |region|
    application_form_traits_for(region).each do |traits|
      application_form = FactoryBot.create(:application_form, *traits, region:)

      next unless application_form.submitted?

      assessment = AssessmentFactory.call(application_form:)

      if application_form.reduced_evidence_accepted ||
           !application_form.needs_work_history
        assessment.update!(induction_required: false)
      end

      if CountryCode.scotland?(application_form.country.code)
        assessment.update!(scotland_full_registration: true)
      end

      if application_form.declined_at.present?
        FactoryBot.create(
          :selected_failure_reason,
          :fi_requestable,
          assessment_section: assessment.sections.first,
          key: assessment.sections.first.failure_reasons.sample,
        )
        FactoryBot.create(
          :selected_failure_reason,
          :declinable,
          assessment_section: assessment.sections.second,
          key: assessment.sections.second.failure_reasons.sample,
        )

        declined_at = Faker::Time.between(from: 6.months.ago, to: Time.zone.now)

        application_form.update!(
          declined_at:,
          submitted_at: declined_at - 2.months,
          created_at: declined_at - 2.months,
        )
      elsif application_form.awarded_at.present?
        awarded_at = Faker::Time.between(from: 6.months.ago, to: Time.zone.now)

        application_form.update!(
          awarded_at:,
          submitted_at: awarded_at - 2.months,
          created_at: awarded_at - 2.months,
        )
      elsif application_form.action_required_by_external?
        create_requestables(application_form, assessment, :requested)
      elsif application_form.action_required_by_admin?
        create_requestables(
          application_form,
          assessment,
          %i[received expired].sample,
        )
      end
    end
  end
end
