# frozen_string_literal: true

class TeacherMailer < ApplicationMailer
  include RegionHelper

  before_action :set_application_form
  before_action :set_further_information_request,
                only: :further_information_reminder
  before_action :set_further_information_requested, only: :application_declined

  helper :application_form, :region

  def application_awarded
    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: teacher.email,
      subject: I18n.t("mailer.teacher.application_awarded.subject"),
    )
  end

  def application_declined
    @view_object =
      TeacherInterface::ApplicationFormViewObject.new(application_form:)

    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: teacher.email,
      subject: I18n.t("mailer.teacher.application_declined.subject"),
    )
  end

  def application_not_submitted
    @number_of_reminders_sent = params[:number_of_reminders_sent]

    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: teacher.email,
      subject:
        I18n.t(
          "mailer.teacher.application_not_submitted.subject.#{@number_of_reminders_sent}",
        ),
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

  def initial_checks_passed
    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: teacher.email,
      subject: I18n.t("mailer.teacher.initial_checks_passed.subject"),
    )
  end

  def professional_standing_received
    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: teacher.email,
      subject:
        I18n.t(
          "mailer.teacher.professional_standing_received.subject",
          certificate: region_certificate_name(region),
        ),
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
  delegate :assessment, :region, to: :application_form

  def set_application_form
    @application_form = application_form
  end

  def set_further_information_request
    @further_information_request = params[:further_information_request]
  end

  def set_further_information_requested
    @further_information_requested =
      assessment.further_information_requests.any?
  end
end
