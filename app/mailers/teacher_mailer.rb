class TeacherMailer < ApplicationMailer
  GOVUK_NOTIFY_TEMPLATE_ID =
    ENV.fetch(
      "GOVUK_NOTIFY_TEMPLATE_ID_TEACHER",
      "95adafaf-0920-4623-bddc-340853c047af"
    )

  def application_received
    teacher = params[:teacher]
    application_form = teacher.application_form

    @name = "#{application_form.given_names} #{application_form.family_name}"
    @reference = application_form.reference

    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: teacher.email,
      subject: I18n.t("mailer.teacher.application_received.subject")
    )
  end
end
