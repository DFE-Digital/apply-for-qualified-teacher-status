# frozen_string_literal: true

class ExpireRequestableJob < ApplicationJob
  def perform(requestable)
    return if requestable.received? || requestable.expired?

    if requestable.expires? && Time.zone.now > requestable.expires_at
      ExpireRequestable.call(requestable:, user: "Expirer")
    end
  end
end
