# frozen_string_literal: true

module Expirable
  extend ActiveSupport::Concern

  def expired_at
    return nil if requested_at.nil? || expires_after.nil?

    requested_at + expires_after
  end

  def after_expired(user:)
    # implement logic after an expiration of this object
  end
end
