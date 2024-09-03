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
      email_address = headers["To"].value
      mailer_action_method = action_name
      mailer_class = mailer_name
      MailDeliveryFailure.create!(
        email_address:,
        mailer_action_method:,
        mailer_class:,
      )
    end

    raise
  end
end
