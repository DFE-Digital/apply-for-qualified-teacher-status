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
        requires_preliminary_check: region.requires_preliminary_check,
        subject_limited: region.country.subject_limited,
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

    unless application_form.teaching_authority_provides_written_statement
      DeliverEmail.call(
        application_form:,
        mailer: TeacherMailer,
        action: :application_received,
      )
    end

    UpdateTRSMatchJob.set(wait: 5.minutes).perform_later(application_form)
  end

  private

  attr_reader :application_form, :user

  delegate :region, to: :application_form

  def create_professional_standing_request(assessment)
    return unless application_form.teaching_authority_provides_written_statement

    requestable = ProfessionalStandingRequest.create!(assessment:)

    if application_form.requires_preliminary_check
      DeliverEmail.call(
        application_form:,
        mailer: TeacherMailer,
        action: :initial_checks_required,
      )
    else
      RequestRequestable.call(requestable:, user:)
    end
  end
end
