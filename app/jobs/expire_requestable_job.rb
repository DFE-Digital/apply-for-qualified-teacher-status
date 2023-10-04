# frozen_string_literal: true

class ExpireRequestableJob < ApplicationJob
  def perform(requestable)
    if requestable.received? || requestable.expired? ||
         !requestable.requested? || requestable.expires_at.nil?
      return
    end

    if Time.zone.now > requestable.expires_at
      ExpireRequestable.call(requestable:, user: "Expirer")
    end
  end
end
