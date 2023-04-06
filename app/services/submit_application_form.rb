class SubmitApplicationForm
  include ServicePattern

  def initialize(application_form:, user:)
    @application_form = application_form
    @user = user
  end

  def call
    return if application_form.submitted_at.present?

    application_form.subjects.compact_blank!
    application_form.submitted_at = Time.zone.now
    application_form.working_days_since_submission = 0

    ApplicationFormStatusUpdater.call(application_form:, user:)

    AssessmentFactory.call(application_form:)

    TeacherMailer
      .with(teacher: application_form.teacher)
      .application_received
      .deliver_later

    if region.teaching_authority_requires_submission_email
      TeachingAuthorityMailer
        .with(application_form:)
        .application_submitted
        .deliver_later
    end
  end

  private

  attr_reader :application_form, :user

  delegate :region, to: :application_form
end
