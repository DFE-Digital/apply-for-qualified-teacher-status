# frozen_string_literal: true

module Requestable
  extend ActiveSupport::Concern

  included do
    enum :state,
         { requested: "requested", received: "received", expired: "expired" },
         default: "requested"

    validates :state, presence: true, inclusion: { in: states.values }

    validates :received_at, presence: true, if: :received?

    define_method :received! do
      update!(state: "received", received_at: Time.zone.now)
    end
  end

  def expired_at
    created_at + expires_after
  end
end
