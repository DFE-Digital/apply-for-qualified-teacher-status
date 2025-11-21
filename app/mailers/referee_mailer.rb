# frozen_string_literal: true

class RefereeMailer < ApplicationMailer
  include ApplicationFormHelper

  before_action :set_reference_request,
                :set_prioritisation_reference_request,
                :set_work_history,
                :set_application_form

  helper :application_form

  def reference_reminder
    @number_of_reminders_sent = params[:number_of_reminders_sent]

    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: work_history.contact_email,
      subject:
        I18n.t(
          "mailer.referee.reference_reminder.subject.#{@number_of_reminders_sent}",
          name: application_form_full_name(application_form),
        ),
    )
  end

  def reference_requested
    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: work_history.contact_email,
      subject:
        I18n.t(
          "mailer.referee.reference_requested.subject",
          name: application_form_full_name(application_form),
        ),
    )
  end

  def prioritisation_reference_reminder
    @number_of_reminders_sent = params[:number_of_reminders_sent]

    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: work_history.contact_email,
      subject:
        I18n.t(
          "mailer.referee.prioritisation_reference_reminder.subject.#{@number_of_reminders_sent}",
          name: application_form_full_name(application_form),
        ),
    )
  end

  def prioritisation_reference_requested
    view_mail(
      GOVUK_NOTIFY_TEMPLATE_ID,
      to: work_history.contact_email,
      subject:
        I18n.t(
          "mailer.referee.prioritisation_reference_requested.subject",
          name: application_form_full_name(application_form),
        ),
    )
  end

  private

  def reference_request
    params[:reference_request]
  end

  def prioritisation_reference_request
    params[:prioritisation_reference_request]
  end

  def work_history
    if reference_request
      reference_request.work_history
    else
      prioritisation_reference_request.work_history
    end
  end

  def application_form
    if reference_request
      reference_request.application_form
    else
      prioritisation_reference_request.application_form
    end
  end

  def set_reference_request
    @reference_request = reference_request
  end

  def set_prioritisation_reference_request
    @prioritisation_reference_request = prioritisation_reference_request
  end

  def set_work_history
    @work_history = work_history
  end

  def set_application_form
    @application_form = application_form
  end
end
