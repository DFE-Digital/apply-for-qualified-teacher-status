# frozen_string_literal: true

# Capture GOV.UK Notify notification response returned by send_email
# and make it available after delivery.
#
# Notify returns a ResponseNotification.
# https://www.rubydoc.info/gems/notifications-ruby-client/2.2.0
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
