# frozen_string_literal: true

module Requestable
  extend ActiveSupport::Concern

  include Expirable

  included do
    belongs_to :assessment

    enum :state,
         { requested: "requested", received: "received", expired: "expired" },
         default: "requested"

    validates :state, presence: true, inclusion: { in: states.values }

    validates :requested_at, presence: true, if: :requested?
    validates :received_at, presence: true, if: :received?
    validates :expired_at, presence: true, if: :expired?
    validates :reviewed_at, presence: true, unless: -> { passed.nil? }

    scope :respondable, -> { not_received.merge(ApplicationForm.assessable) }

    define_method :requested! do
      update!(state: "requested", requested_at: Time.zone.now)
    end

    define_method :received! do
      update!(state: "received", received_at: Time.zone.now)
    end

    define_method :expired! do
      update!(state: "expired", expired_at: Time.zone.now)
    end

    has_one :application_form, through: :assessment
  end

  def reviewed!(passed)
    update!(passed:, reviewed_at: Time.zone.now)
  end

  def reviewed?
    passed != nil
  end

  def overdue?
    expired? || (received? && expires_at.present? && received_at > expires_at)
  end

  def failed
    return nil if passed.nil?
    passed == false
  end

  def status
    return state if passed.nil?

    passed ? "accepted" : "rejected"
  end

  def after_requested(user:)
    # implement logic after this requestable has been requested
  end

  def after_received(user:)
    # implement logic after this requestable has been received
  end

  def after_reviewed(user:)
    # implement logic after this requestable has been reviewed
  end
end
