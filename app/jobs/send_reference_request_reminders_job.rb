# frozen_string_literal: true

class SendReferenceRequestRemindersJob < ApplicationJob
  def perform
    ReferenceRequest.requested.find_each do |reference_request|
      SendReferenceRequestReminderJob.perform_later(reference_request:)
    end
  end
end
