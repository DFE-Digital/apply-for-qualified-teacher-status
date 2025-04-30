# frozen_string_literal: true

require "devise/passwordless/mailer"

class DeviseMailer < Devise::Passwordless::Mailer
  GOVUK_NOTIFY_TEMPLATE_ID =
    ENV.fetch(
      "GOVUK_NOTIFY_TEMPLATE_ID_DEVISE",
      "4981b601-eaab-46a3-9f6a-7a42cdd0d4cf",
    )

  def devise_mail(record, action, opts = {}, &_block)
    initialize_from_record(record)
    view_mail(GOVUK_NOTIFY_TEMPLATE_ID, headers_for(action, opts))
  end
end
