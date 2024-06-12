# frozen_string_literal: true

class ExpireRequestablesJob < ApplicationJob
  def perform(requestable_class_name)
    requestable_class_name
      .constantize
      .requested
      .not_received
      .not_expired
      .each do |requestable|
      if requestable.expires? && Time.zone.now > requestable.expires_at
        ExpireRequestable.call(requestable:, user: "Expirer")
      end
    end
  end
end
