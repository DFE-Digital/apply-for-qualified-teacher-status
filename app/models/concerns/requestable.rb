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
    validates :reviewed_at, presence: true, unless: -> { passed.nil? }

    define_method :received! do
      update!(state: "received", received_at: Time.zone.now)
    end

    delegate :application_form, to: :assessment
  end

  def expired_at
    created_at + expires_after
  end

  def reviewed!(passed)
    update!(passed:, reviewed_at: Time.zone.now)
  end

  def failed
    return nil if passed.nil?
    passed == false
  end

  def status
    return state if passed.nil?

    passed ? "accepted" : "rejected"
  end

  def after_received(user:)
    # implement logic after this requestable has been received
  end

  def after_expired(user:)
    # implement logic after an expiration of this requestable
  end

  def after_reviewed(user:)
    # implement logic after this requestable has been reviewed
  end
end
