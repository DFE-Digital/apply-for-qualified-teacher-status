# frozen_string_literal: true

class TeacherMailer < ApplicationMailer
  before_action :set_application_form
  before_action :set_further_information_requested, only: :application_declined
  before_action :set_due_date, only: :further_information_reminder

  helper :application_form

  def application_awarded
    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: teacher.email,
      subject: I18n.t("mailer.teacher.application_awarded.subject"),
    )
  end

  def application_declined
    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: teacher.email,
      subject: I18n.t("mailer.teacher.application_declined.subject"),
    )
  end

  def application_not_submitted
    @duration = params[:duration]
    @destruction_date = application_form.expired_at.to_date

    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: teacher.email,
      subject:
        I18n.t("mailer.teacher.application_not_submitted.subject.#{@duration}"),
    )
  end

  def application_received
    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: teacher.email,
      subject: I18n.t("mailer.teacher.application_received.subject"),
    )
  end

  def further_information_received
    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: teacher.email,
      subject: I18n.t("mailer.teacher.further_information_received.subject"),
    )
  end

  def further_information_requested
    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: teacher.email,
      subject: I18n.t("mailer.teacher.further_information_requested.subject"),
    )
  end

  def further_information_reminder
    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: teacher.email,
      subject: I18n.t("mailer.teacher.further_information_reminder.subject"),
    )
  end

  def references_requested
    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: teacher.email,
      subject: I18n.t("mailer.teacher.references_requested.subject"),
    )
  end

  private

  def teacher
    params[:teacher]
  end

  delegate :application_form, to: :teacher
  delegate :assessment, to: :application_form

  def set_application_form
    @application_form = application_form
  end

  def set_further_information_requested
    @further_information_requested =
      assessment.further_information_requests.any?
  end

  def set_due_date
    @due_date = params[:due_date]
  end
end
