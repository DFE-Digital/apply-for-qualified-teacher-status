class SubmitApplicationForm
  include ServicePattern

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    return if application_form.submitted?

    application_form.subjects.compact_blank!
    application_form.submitted_at = Time.zone.now
    application_form.submitted!

    TeacherMailer
      .with(teacher: application_form.teacher)
      .application_received
      .deliver_later
  end

  private

  attr_reader :application_form
end
