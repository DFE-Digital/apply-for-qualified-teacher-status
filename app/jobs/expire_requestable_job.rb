# frozen_string_literal: true

class ExpireRequestableJob < ApplicationJob
  def perform(requestable)
    if requestable.requested? && requestable.expired_at.present? &&
         Time.zone.now > requestable.expired_at
      ExpireRequestable.call(requestable:, user: "Expirer")
    end
  end
end
