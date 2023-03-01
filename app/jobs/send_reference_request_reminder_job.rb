# frozen_string_literal: true

class SendReferenceRequestReminderJob < ApplicationJob
  def perform(reference_request:)
    ReferenceRequestReminder.call(reference_request:)
  end
end
