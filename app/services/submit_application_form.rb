class SubmitApplicationForm
  include ServicePattern

  def initialize(application_form:, user:)
    @application_form = application_form
    @user = user
  end

  def call
    return if application_form.submitted?

    application_form.subjects.compact_blank!
    application_form.submitted_at = Time.zone.now
    application_form.working_days_since_submission = 0

    ChangeApplicationFormState.call(
      application_form:,
      user:,
      new_state: "submitted",
    )

    AssessmentFactory.call(application_form:)

    TeacherMailer
      .with(teacher: application_form.teacher)
      .application_received
      .deliver_later
  end

  private

  attr_reader :application_form, :user
end
