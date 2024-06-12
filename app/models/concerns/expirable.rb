# frozen_string_literal: true

module Expirable
  extend ActiveSupport::Concern

  included do
    scope :expired, -> { where.not(expired_at: nil) }
    scope :not_expired, -> { where(expired_at: nil) }
  end

  def expires_at
    return nil if received_at || requested_at.nil? || expires_after.nil?

    requested_at + expires_after
  end

  def expires?
    expires_at != nil
  end

  def days_until_expired
    @days_until_expired ||=
      expires? ? (expires_at.to_date - Time.zone.today).to_i : nil
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
