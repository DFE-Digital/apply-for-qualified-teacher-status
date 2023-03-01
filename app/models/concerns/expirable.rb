# frozen_string_literal: true

module Expirable
  extend ActiveSupport::Concern

  def expired_at
    expires_after ? created_at + expires_after : nil
  end

  def after_expired(user:)
    # implement logic after an expiration of this object
  end
end
