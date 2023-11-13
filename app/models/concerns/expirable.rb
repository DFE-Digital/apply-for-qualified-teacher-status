# frozen_string_literal: true

module Expirable
  extend ActiveSupport::Concern

  def expires_at
    return nil if requested_at.nil? || expires_after.nil?

    requested_at + expires_after
  end

  def days_until_expired
    return nil if expires_at.nil?
    (expires_at.to_date - Time.zone.today).to_i
  end

  def expired!
    update!(expired_at: Time.zone.now)
  end

  def expired?
    expired_at != nil
  end

  def after_expired(user:)
    # implement logic after an expiration of this object
  end
end
