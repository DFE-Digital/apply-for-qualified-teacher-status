# frozen_string_literal: true

class ApplicationMailer < Mail::Notify::Mailer
  default from: I18n.t("service.email.enquiries")

  after_deliver :create_email_delivery_audit

  GOVUK_NOTIFY_TEMPLATE_ID =
    ENV.fetch(
      "GOVUK_NOTIFY_TEMPLATE_ID_APPLICATION",
      "7f036b52-9e08-40c9-8b52-0bb527d70f4a",
    )

  private

  def create_email_delivery_audit
    notify_id =
      if message.delivery_method.respond_to?(:response)
        message.delivery_method.response&.id
      end

    email_delivery =
      EmailDelivery.create!(
        to: headers["To"].value,
        subject: headers["Subject"].value,
        notify_id:,
        mailer_class_name: mailer_name,
        mailer_action_name: action_name,
        application_form: params[:application_form],
        further_information_request: params[:further_information_request],
        reference_request: params[:reference_request],
        prioritisation_reference_request:
          params[:prioritisation_reference_request],
      )

    if notify_id
      EmailDeliveryNotifyStatusUpdateJob.set(wait: 1.minute).perform_later(
        email_delivery,
      )
    end
  end
end
