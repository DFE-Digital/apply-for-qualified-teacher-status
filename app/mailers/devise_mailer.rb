# frozen_string_literal: true

require "devise/passwordless/mailer"

class DeviseMailer < Devise::Passwordless::Mailer
  GOVUK_NOTIFY_TEMPLATE_ID =
    ENV.fetch(
      "GOVUK_NOTIFY_TEMPLATE_ID_DEVISE",
      "8331da6b-6e8a-4782-ab56-2a74200d51d2",
    )

  def devise_mail(record, action, opts = {}, &_block)
    initialize_from_record(record)
    view_mail(GOVUK_NOTIFY_TEMPLATE_ID, headers_for(action, opts))
  end
end
