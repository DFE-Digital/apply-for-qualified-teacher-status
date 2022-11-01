class TeacherMailer < ApplicationMailer
  before_action :set_name
  before_action :set_reference,
                only: %i[
                  application_awarded
                  application_declined
                  application_received
                ]

  GOVUK_NOTIFY_TEMPLATE_ID =
    ENV.fetch(
      "GOVUK_NOTIFY_TEMPLATE_ID_TEACHER",
      "95adafaf-0920-4623-bddc-340853c047af",
    )

  def application_awarded
    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: params[:teacher].email,
      subject: I18n.t("mailer.teacher.application_awarded.subject"),
    )
  end

  def application_declined
    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: params[:teacher].email,
      subject: I18n.t("mailer.teacher.application_declined.subject"),
    )
  end

  def application_received
    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: params[:teacher].email,
      subject: I18n.t("mailer.teacher.application_received.subject"),
    )
  end

  def further_information_requested
    teacher = params[:teacher]

    @date = "[date]"

    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: teacher.email,
      subject: I18n.t("mailer.teacher.further_information_requested.subject"),
    )
  end

  private

  def set_name
    application_form = params[:teacher].application_form
    @name = "#{application_form.given_names} #{application_form.family_name}"
  end

  def set_reference
    @reference = params[:teacher].application_form.reference
  end
end
