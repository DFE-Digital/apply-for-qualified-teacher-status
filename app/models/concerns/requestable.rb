# frozen_string_literal: true

module Requestable
  extend ActiveSupport::Concern

  included do
    belongs_to :assessment

    enum :state,
         { requested: "requested", received: "received", expired: "expired" },
         default: "requested"

    validates :state, presence: true, inclusion: { in: states.values }

    validates :received_at, presence: true, if: :received?

    define_method :received! do
      update!(state: "received", received_at: Time.zone.now)
    end

    delegate :application_form, to: :assessment
  end

  def expired_at
    created_at + expires_after
  end

  def after_received(user:)
    # implement logic after this requestable has been received
  end

  def after_expired(user:)
    # implement logic after an expiration of this requestable
  end
end
