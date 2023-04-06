# frozen_string_literal: true

class SendFurtherInformationRequestRemindersJob < ApplicationJob
  def perform
    FurtherInformationRequest
      .requested
      .find_each do |further_information_request|
      SendFurtherInformationRequestReminderJob.perform_later(
        further_information_request:,
      )
    end
  end
end
