# frozen_string_literal: true

class ApplicationMailer < Mail::Notify::Mailer
  default from: I18n.t("service.email.enquiries")

  after_deliver :enqueue_email_delivery_audit

  GOVUK_NOTIFY_TEMPLATE_ID =
    ENV.fetch(
      "GOVUK_NOTIFY_TEMPLATE_ID_APPLICATION",
      "7f036b52-9e08-40c9-8b52-0bb527d70f4a",
    )

  private

  def enqueue_email_delivery_audit
    notify_id =
      if message.delivery_method.respond_to?(:response)
        message.delivery_method.response&.id
      end

    EmailDeliveryAuditJob.perform_later(
      headers["To"].value,
      headers["Subject"].value,
      notify_id,
      mailer_name,
      action_name,
      params,
    )
  end
end
