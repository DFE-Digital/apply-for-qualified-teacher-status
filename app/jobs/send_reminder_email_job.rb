# frozen_string_literal: true

class SendReminderEmailJob < ApplicationJob
  def perform(remindable)
    SendReminderEmail.call(remindable:)
  end
end
