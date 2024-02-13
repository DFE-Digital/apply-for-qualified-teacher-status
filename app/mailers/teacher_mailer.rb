# frozen_string_literal: true

class TeacherMailer < ApplicationMailer
  include RegionHelper

  before_action :set_application_form

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

  def application_from_ineligible_country
    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: teacher.email,
      subject:
        I18n.t("mailer.teacher.application_from_ineligible_country.subject"),
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

  def consent_reminder
    @expires_at =
      assessment.qualification_requests.consent_required.map(&:expires_at).max

    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: teacher.email,
      subject: I18n.t("mailer.teacher.consent_reminder.subject"),
    )
  end

  def consent_requested
    @expires_at =
      assessment.qualification_requests.consent_required.map(&:expires_at).max

    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: teacher.email,
      subject: I18n.t("mailer.teacher.consent_requested.subject"),
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
    @further_information_request = params[:further_information_request]

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

  def references_reminder
    @number_of_reminders_sent = params[:number_of_reminders_sent]
    @reference_requests = params[:reference_requests]

    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: teacher.email,
      subject:
        I18n.t(
          "mailer.teacher.references_reminder.subject.#{@number_of_reminders_sent}",
        ),
    )
  end

  def references_requested
    @reference_requests = params[:reference_requests]

    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: teacher.email,
      subject: I18n.t("mailer.teacher.references_requested.subject"),
    )
  end

  private

  def application_form
    params[:application_form]
  end

  delegate :assessment, :region, :teacher, to: :application_form

  def set_application_form
    @application_form = application_form
  end
end
