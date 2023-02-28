# frozen_string_literal: true

class ExpireRequestablesJob < ApplicationJob
  def perform(requestable_class_name)
    requestable_class_name.constantize.requested.find_each do |requestable|
      ExpireRequestableJob.perform_later(requestable)
    end
  end
end
