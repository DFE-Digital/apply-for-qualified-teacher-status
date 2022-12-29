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
  after_action :store_observer_metadata

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

  def store_observer_metadata
    mailer_action_name = action_name
    application_form_id = params[:teacher].application_form.id

    message.instance_variable_set(:@mailer_action_name, mailer_action_name)
    message.instance_variable_set(:@application_form_id, application_form_id)

    message.class.send(:attr_reader, :mailer_action_name)
    message.class.send(:attr_reader, :application_form_id)
  end
end
