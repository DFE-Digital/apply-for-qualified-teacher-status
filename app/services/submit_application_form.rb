# frozen_string_literal: true

class SubmitApplicationForm
  include ServicePattern

  def initialize(application_form:, user:)
    @application_form = application_form
    @user = user
  end

  def call
    return if application_form.submitted_at.present?

    ActiveRecord::Base.transaction do
      application_form.update!(
        hidden_from_assessment:,
        requires_preliminary_check: region.requires_preliminary_check,
        subjects: application_form.subjects.compact_blank,
        submitted_at: Time.zone.now,
        working_days_since_submission: 0,
      )

      assessment = AssessmentFactory.call(application_form:)

      if application_form.reduced_evidence_accepted
        UpdateAssessmentInductionRequired.call(assessment:)
      end

      create_professional_standing_request(assessment)

      application_form.reload

      ApplicationFormStatusUpdater.call(application_form:, user:)
    end

    TeacherMailer
      .with(teacher: application_form.teacher)
      .application_received
      .deliver_later

    if !application_form.requires_preliminary_check &&
         application_form.teaching_authority_provides_written_statement
      TeacherMailer
        .with(teacher: application_form.teacher)
        .initial_checks_passed
        .deliver_later
    end

    if region.teaching_authority_requires_submission_email
      TeachingAuthorityMailer
        .with(application_form:)
        .application_submitted
        .deliver_later
    end

    FindApplicantInDQTJob.perform_later(
      application_form_id: application_form.id,
    )

    # Sometimes DQT doesn't find a result the first time
    FindApplicantInDQTJob.set(wait: 5.minutes).perform_later(
      application_form_id: application_form.id,
    )
  end

  private

  attr_reader :application_form, :user

  delegate :region, to: :application_form

  def create_professional_standing_request(assessment)
    return unless application_form.teaching_authority_provides_written_statement

    ProfessionalStandingRequest
      .create!(assessment:)
      .tap { |requestable| RequestRequestable.call(requestable:, user:) }
  end

  def hidden_from_assessment
    region.country.code == "ZW"
  end
end
