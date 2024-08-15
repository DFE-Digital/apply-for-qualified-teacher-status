# frozen_string_literal: true

class ApplicationMailer < Mail::Notify::Mailer
  default from: I18n.t("service.email.enquiries")

  GOVUK_NOTIFY_TEMPLATE_ID =
    ENV.fetch(
      "GOVUK_NOTIFY_TEMPLATE_ID_APPLICATION",
      "95adafaf-0920-4623-bddc-340853c047af",
    )

  rescue_from Notifications::Client::RequestError do
    # WARNING: this needs to be a block, otherwise the exception will not be
    # re-raised and we will not be notified via Sentry, and the job will not retry.
    #
    # @see https://github.com/rails/rails/issues/39018
    if respond_to?(:headers)
      recipient_email = headers["To"].value
      MailDeliveryFailure.create!(recipient_email:)
    end

    raise
  end

  def notify_email(headers)
    headers =
      headers.merge(rails_mailer: mailer_name, rails_mail_template: action_name)
    view_mail(GOVUK_NOTIFY_TEMPLATE_ID, headers)
  end
end
