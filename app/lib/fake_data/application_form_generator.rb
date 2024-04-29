# frozen_string_literal: true

class FakeData::ApplicationFormGenerator
  include ServicePattern

  def initialize(region:, params:)
    @region = region
    @params = FakeData::ApplicationFormParameters.new(**params)
  end

  def call
    create_application_form

    return application_form unless params.submit?

    submit_application_form

    return application_form unless params.pre_assess?

    if application_form.requires_preliminary_check
      pre_assess_application_form(decline: params.decline_after_pre_assessment?)
    end

    if application_form.teaching_authority_provides_written_statement &&
         params.receive_professional_standing?
      receive_professional_standing
    end

    if params.decline_after_pre_assessment?
      decline_application_form
      return application_form
    end

    return application_form unless params.assess?

    assess_application_form(
      decline: params.decline_after_assessment?,
      further_information: params.request_further_information?,
    )

    if params.decline_after_assessment?
      decline_application_form
      return application_form
    end

    request_further_information if params.request_further_information?

    receive_further_information if params.receive_further_information?

    if params.decline_after_further_information?
      review_further_information(passed: false)
      decline_application_form
      return application_form
    end

    return application_form unless params.verify?

    if params.receive_further_information?
      review_further_information(passed: true)
    end

    verify_application_form

    return application_form unless params.request_verification?

    request_verification

    overdue_verification if params.expire_verification?

    return application_form unless params.receive_verification?

    receive_references_and_consent

    unless params.review? || params.decline_after_review? || params.award?
      return application_form
    end

    verify_verification(passed: !params.review?)

    if params.decline_after_review?
      review_verification(passed: false)
      decline_application_form
    elsif params.award?
      review_verification(passed: true) if params.review?
      award_application_form(user: params.review? ? assessor_user : admin_user)
    end

    application_form
  end

  private

  attr_reader :region, :params, :application_form

  delegate :assessment, to: :application_form

  def create_application_form
    traits = %i[
      with_personal_information
      with_degree_qualification
      with_identification_document
      with_age_range
      with_subjects
    ]

    traits << %i[
      with_english_language_medium_of_instruction
      with_english_language_provider
      with_english_language_exemption_by_citizenship
      with_english_language_exemption_by_qualification
    ].sample

    unless region.application_form_skip_work_history
      traits << :with_work_history
    end

    if region.status_check_written? || region.sanction_check_written?
      traits << :with_written_statement
    end

    if region.status_check_online? || region.sanction_check_online?
      traits << :with_registration_number
    end

    @application_form =
      FactoryBot.create(
        :application_form,
        *traits,
        created_at: date_generator.date,
        region:,
      )
  end

  def submit_application_form
    date_generator.travel_to_next_long do
      SubmitApplicationForm.call(
        application_form:,
        user: application_form.teacher,
      )
    end
  end

  def pre_assess_application_form(decline:)
    date_generator.next_long

    user = admin_user

    assessment.sections.preliminary.each do |assessment_section|
      date_generator.travel_to_next_short do
        if decline
          AssessAssessmentSection.call(
            assessment_section:,
            user:,
            passed: false,
            selected_failure_reasons: {
              assessment_section.failure_reasons.sample => {
                notes: "",
              },
            },
          )
        else
          AssessAssessmentSection.call(assessment_section:, user:, passed: true)
        end
      end
    end

    AssignApplicationFormAssessor.call(application_form:, user:, assessor: nil)
  end

  def receive_professional_standing
    requestable = assessment.professional_standing_request

    date_generator.travel_to_next_long do
      if application_form.teaching_authority_provides_written_statement
        requestable.update!(location_note: Faker::Lorem.sentence)
      end

      ReceiveRequestable.call(requestable:, user: admin_user)
    end
  end

  def assess_application_form(decline: false, further_information: false)
    user = assessor_user

    assessment.sections.not_preliminary.each do |assessment_section|
      params =
        if decline || further_information
          failure_reasons =
            assessment_section.failure_reasons.filter do |failure_reason|
              (
                further_information &&
                  FailureReasons.further_information?(failure_reason)
              ) || (decline && FailureReasons.decline?(failure_reason))
            end

          if failure_reasons.empty?
            { passed: true }
          else
            {
              passed: false,
              selected_failure_reasons:
                failure_reasons
                  .sample(rand(1..3))
                  .index_with do |failure_reason|
                    {
                      notes: Faker::Lorem.sentence,
                      work_histories:
                        (
                          if FailureReasons.chooses_work_history?(
                               failure_reason,
                             )
                            application_form.work_histories
                          else
                            []
                          end
                        ),
                    }
                  end,
            }
          end
        else
          { passed: true }
        end

      date_generator.travel_to_next_long do
        if assessment_section.age_range_subjects?
          VerifyAgeRangeSubjects.call(
            assessment:,
            user:,
            age_range_min: assessment.age_range_min,
            age_range_max: assessment.age_range_max,
            age_range_note: Faker::Lorem.sentence,
            subjects: Subject.all.sample(rand(1..3)).map(&:value),
            subjects_note: Faker::Lorem.sentence,
          )
        end

        AssessAssessmentSection.call(assessment_section:, user:, **params)
      end
    end
  end

  def request_further_information
    date_generator.travel_to_next_short do
      RequestFurtherInformation.call(
        assessment:,
        user: application_form.assessor,
      )
    end
  end

  def receive_further_information
    assessment
      .further_information_requests
      .each do |further_information_request|
      further_information_request.items.each do |item|
        if item.text?
          item.update!(response: Faker::Lorem.sentence)
        elsif item.document?
          FactoryBot.create(:upload, document: item.document)
        elsif item.work_history_contact?
          item.update!(
            contact_name: Faker::Name.name,
            contact_job: Faker::Job.title,
            contact_email: Faker::Internet.email,
          )
        end
      end

      date_generator.travel_to_next_long do
        ReceiveRequestable.call(
          requestable: further_information_request,
          user: application_form.teacher,
        )
      end
    end
  end

  def review_further_information(passed:)
    assessment
      .further_information_requests
      .each do |further_information_request|
      date_generator.travel_to_next_long do
        ReviewRequestable.call(
          requestable: further_information_request,
          user: assessor_user,
          passed:,
          note: Faker::Lorem.sentence,
        )
      end
    end
  end

  def verify_application_form
    professional_standing =
      if application_form.teaching_authority_provides_written_statement ||
           application_form.reduced_evidence_accepted ||
           !application_form.needs_work_history
        false
      else
        [true, false].sample
      end

    qualifications = application_form.qualifications.sample(rand(0..2))
    qualifications_assessor_note = Faker::Lorem.sentence

    work_histories =
      if application_form.reduced_evidence_accepted ||
           !application_form.needs_work_history
        []
      else
        application_form.work_histories
      end

    date_generator.travel_to_next_long do
      VerifyAssessment.call(
        assessment:,
        user: assessor_user,
        professional_standing:,
        qualifications:,
        qualifications_assessor_note:,
        work_histories:,
      )
    end
  end

  def request_verification
    user = admin_user

    date_generator.next_long

    if assessment.professional_standing_request.present? &&
         !application_form.teaching_authority_provides_written_statement
      date_generator.travel_to_date do
        RequestRequestable.call(
          requestable: assessment.professional_standing_request,
          user:,
        )
      end
    end

    assessment.qualification_requests.each do |requestable|
      requestable.update!(
        consent_method: %w[
          signed_ecctis
          signed_institution
          unsigned
          none
        ].sample,
      )

      if requestable.consent_method_signed?
        consent_request =
          assessment.consent_requests.create!(
            qualification: requestable.qualification,
          )
        FactoryBot.create(
          :upload,
          document: consent_request.unsigned_consent_document,
        )
      elsif requestable.consent_method_unsigned?
        assessment.update!(unsigned_consent_document_generated: true)
      end

      next if requestable.consent_method_signed?
      date_generator.travel_to_next_short do
        RequestRequestable.call(requestable:, user:)
      end
    end

    date_generator.travel_to_next_short do
      RequestConsent.call(assessment:, user:)
    end
  end

  def receive_references_and_consent
    assessment.reference_requests.each do |requestable|
      contact_response = [true, false].sample
      dates_response = [true, false].sample
      hours_response = [true, false].sample
      children_response = [true, false].sample
      lessons_response = [true, false].sample
      reports_response = [true, false].sample
      misconduct_response = [true, false].sample
      satisfied_response = [true, false].sample

      requestable.update!(
        contact_response:,
        contact_name: contact_response ? "" : Faker::Name.name,
        contact_job: contact_response ? "" : Faker::Job.title,
        contact_comment: contact_response ? "" : Faker::Lorem.sentence,
        dates_response:,
        dates_comment: dates_response ? "" : Faker::Lorem.sentence,
        hours_response:,
        hours_comment: hours_response ? "" : Faker::Lorem.sentence,
        children_response:,
        children_comment: children_response ? "" : Faker::Lorem.sentence,
        lessons_response:,
        lessons_comment: lessons_response ? "" : Faker::Lorem.sentence,
        reports_response:,
        reports_comment: reports_response ? "" : Faker::Lorem.sentence,
        misconduct_response:,
        misconduct_comment: misconduct_response ? Faker::Lorem.sentence : "",
        satisfied_response:,
        satisfied_comment: satisfied_response ? "" : Faker::Lorem.sentence,
        additional_information_response: Faker::Lorem.sentence,
      )

      date_generator.travel_to_next_long do
        ReceiveRequestable.call(
          requestable:,
          user: requestable.work_history.contact_email,
        )
      end
    end

    assessment.consent_requests.each do |requestable|
      FactoryBot.create(:upload, document: requestable.signed_consent_document)

      date_generator.travel_to_next_long do
        ReceiveRequestable.call(requestable:, user: application_form.teacher)
      end
    end
  end

  def overdue_verification
    user = "Expirer"

    requestables
      .filter(&:requested?)
      .each do |requestable|
        date_generator.travel_to_next_long do
          ExpireRequestable.call(requestable:, user:)
        end
      end
  end

  def verify_verification(passed:)
    user = admin_user

    if passed
      assessment.consent_requests.each do |requestable|
        date_generator.travel_to_next_short do
          VerifyRequestable.call(requestable:, user:, passed: true, note: "")
        end
      end

      assessment
        .qualification_requests
        .reject(&:requested?)
        .each do |requestable|
          date_generator.travel_to_next_short do
            RequestRequestable.call(requestable:, user:)
          end
        end
    end

    requestables
      .select(&:requested?)
      .reject(&:verified?)
      .each do |requestable|
        date_generator.travel_to_next_short do
          if !requestable.received? && (passed || [true, false].sample)
            ReceiveRequestable.call(requestable:, user:)
          end

          VerifyRequestable.call(
            requestable:,
            user:,
            passed:,
            note: Faker::Lorem.sentence,
          )
        end
      end

    unless passed
      date_generator.travel_to_next_short do
        ReviewAssessment.call(assessment:, user:)
      end
    end
  end

  def review_verification(passed:)
    user = assessor_user

    requestables
      .reject(&:reviewed?)
      .each do |requestable|
        date_generator.travel_to_next_short do
          ReviewRequestable.call(
            requestable:,
            user:,
            passed:,
            note: Faker::Lorem.sentence,
          )
        end
      end
  end

  def award_application_form(user:)
    assessment.award!

    trn = Faker::Number.leading_zero_number(digits: 10)
    access_your_teaching_qualifications_url = Faker::Internet.url

    date_generator.travel_to_next_long do
      DQTTRNRequest.create!(request_id: SecureRandom.uuid, application_form:)
      ApplicationFormStatusUpdater.call(application_form:, user:)
    end

    date_generator.travel_to_next_short do
      AwardQTS.call(
        application_form:,
        user:,
        trn:,
        access_your_teaching_qualifications_url:,
      )
    end
  end

  def decline_application_form
    assessment.decline!

    date_generator.travel_to_next_long do
      DeclineQTS.call(application_form:, user: assessor_user)
    end
  end

  def requestables
    assessment.reference_requests.to_a +
      assessment.qualification_requests.to_a +
      assessment.consent_requests.to_a +
      (
        if assessment.professional_standing_request.present? &&
             !application_form.teaching_authority_provides_written_statement
          [assessment.professional_standing_request]
        else
          []
        end
      )
  end

  def date_generator
    @date_generator ||= FakeData::DateGenerator.new
  end

  def assessor_user
    Staff.where(assess_permission: true).sample
  end

  def admin_user
    Staff.where(verify_permission: true).sample
  end

  def manager_user
    Staff.where(withdraw_permission: true).sample
  end
end
