# frozen_string_literal: true

# Capture GOV.UK Notify notification response returned by send_email
# and make it available after delivery.
#
# Notify returns a ResponseNotification.
# https://www.rubydoc.info/gems/notifications-ruby-client/2.2.0
#
# TODO: We have an open PR https://github.com/dxw/mail-notify/pull/200
# for the mail-notify gem to handle this. Once this has been released
# we can remove this patch and re-test to ensure our funtionality for
# GOV.UK Notify delivery status tracking still works.

LAST_TESTED_VERSION = "2.0.0"

require "mail/notify/version"

unless Mail::Notify::VERSION == LAST_TESTED_VERSION
  raise "mail-notify is version #{Mail::Notify::VERSION} but " \
          "the patch was last tested on #{LAST_TESTED_VERSION} - manually check " \
          "if this can be removed, or that it still works as intended"
end

module CaptureNotifyResponsePatch
  def deliver!(message)
    response = super

    # response assessor already exists
    # https://github.com/dxw/mail-notify/blob/main/lib/mail/notify/delivery_method.rb#L6
    self.response = response

    response
  end
end

Mail::Notify::DeliveryMethod.prepend(CaptureNotifyResponsePatch)
