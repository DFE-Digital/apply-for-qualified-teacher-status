# frozen_string_literal: true

class SendFurtherInformationRequestReminderJob < ApplicationJob
  def perform(further_information_request:)
    FurtherInformationRequestReminder.call(further_information_request:)
  end
end
