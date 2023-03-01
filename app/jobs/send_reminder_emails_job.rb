# frozen_string_literal: true

class SendReminderEmailsJob < ApplicationJob
  def perform(remindable_class_name)
    remindable_class_name.constantize.requested.find_each do |remindable|
      SendReminderEmailJob.perform_later(remindable)
    end
  end
end
