# frozen_string_literal: true

class ExpireRequestableJob < ApplicationJob
  def perform(requestable)
    if requestable.requested? && requestable.expires_at.present? &&
         Time.zone.now > requestable.expires_at
      ExpireRequestable.call(requestable:, user: "Expirer")
    end
  end
end
