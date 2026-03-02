# frozen_string_literal: true

class EmailDeliveryNotifyStatusUpdateJob < ApplicationJob
  def perform(email_delivery)
    return unless email_delivery.notify_id
    return unless email_delivery.notify_status_created?

    client = Notifications::Client.new(ENV["GOVUK_NOTIFY_V2_API_KEY"])

    notification = client.get_notification(email_delivery.notify_id)

    if notification.completed_at.present?
      email_delivery.update!(
        notify_status: notification.status,
        notify_completed_at: notification.completed_at,
      )
    else
      EmailDeliveryNotifyStatusUpdateJob.set(wait: 1.minute).perform_later(
        email_delivery,
      )
    end
  end
end
