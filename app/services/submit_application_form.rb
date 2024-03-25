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
        requires_preliminary_check:,
        subjects: application_form.subjects.compact_blank,
        submitted_at: Time.zone.now,
        working_days_since_submission: 0,
      )

      assessment = AssessmentFactory.call(application_form:)

      if reduced_evidence_accepted
        UpdateAssessmentInductionRequired.call(assessment:)
      end

      create_professional_standing_request(assessment)

      application_form.reload

      ApplicationFormStatusUpdater.call(application_form:, user:)
    end

    DeliverEmail.call(
      application_form:,
      mailer: TeacherMailer,
      action: :application_received,
    )

    if teaching_authority_requires_submission_email
      DeliverEmail.call(
        application_form:,
        mailer: TeachingAuthorityMailer,
        action: :application_submitted,
      )
    end

    perform_duplicate_jobs
  end

  private

  attr_reader :application_form, :user

  delegate :reduced_evidence_accepted,
           :region,
           :requires_preliminary_check,
           :teaching_authority_provides_written_statement,
           to: :application_form

  delegate :teaching_authority_requires_submission_email, to: :region

  def create_professional_standing_request(assessment)
    return unless teaching_authority_provides_written_statement

    ProfessionalStandingRequest
      .create!(assessment:)
      .tap { |requestable| RequestRequestable.call(requestable:, user:) }
  end

  def perform_duplicate_jobs
    FindApplicantInDQTJob.perform_later(application_form)

    # Sometimes DQT doesn't find a result the first time
    FindApplicantInDQTJob.set(wait: 5.minutes).perform_later(application_form)
  end
end
