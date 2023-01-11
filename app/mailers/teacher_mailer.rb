# frozen_string_literal: true

class TeacherMailer < ApplicationMailer
  before_action :set_name
  before_action :set_reference,
                only: %i[
                  application_awarded
                  application_declined
                  application_received
                  further_information_received
                  further_information_reminder
                ]
  before_action :set_further_information_requested, only: :application_declined
  before_action :set_due_date, only: :further_information_reminder

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

  def application_not_submitted
    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: params[:teacher].email,
      subject:
        I18n.t(
          "mailer.teacher.application_not_submitted.subject.#{params[:duration]}",
        ),
    )
  end

  def application_received
    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: params[:teacher].email,
      subject: I18n.t("mailer.teacher.application_received.subject"),
    )
  end

  def further_information_received
    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: params[:teacher].email,
      subject: I18n.t("mailer.teacher.further_information_received.subject"),
    )
  end

  def further_information_requested
    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: params[:teacher].email,
      subject: I18n.t("mailer.teacher.further_information_requested.subject"),
    )
  end

  def further_information_reminder
    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: params[:teacher].email,
      subject: I18n.t("mailer.teacher.further_information_reminder.subject"),
    )
  end

  private

  def set_name
    @name =
      if application_form.given_names.present? ||
           application_form.family_name.present?
        "#{application_form.given_names} #{application_form.family_name}"
      else
        "applicant"
      end
  end

  def set_reference
    @reference = params[:teacher].application_form.reference
  end

  def set_due_date
    @due_date = params[:due_date]
  end

  def set_further_information_requested
    @further_information_requested =
      assessment.further_information_requests.any?
  end

  def application_form
    params[:teacher].application_form
  end

  def assessment
    application_form.assessment
  end
end
