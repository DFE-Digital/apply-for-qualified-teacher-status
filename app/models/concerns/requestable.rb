# frozen_string_literal: true

module Requestable
  extend ActiveSupport::Concern

  include Expirable

  included do
    belongs_to :assessment

    validates :reviewed_at, presence: true, unless: -> { passed.nil? }

    scope :requested, -> { where.not(requested_at: nil) }
    scope :received, -> { where.not(received_at: nil) }
    scope :respondable,
          -> do
            requested.where(received_at: nil).merge(ApplicationForm.assessable)
          end

    has_one :application_form, through: :assessment
  end

  def requested!
    update!(requested_at: Time.zone.now)
  end

  def requested?
    requested_at != nil
  end

  def received!
    update!(received_at: Time.zone.now)
  end

  def received?
    received_at != nil
  end

  def reviewed!(passed)
    update!(passed:, reviewed_at: Time.zone.now)
  end

  def reviewed?
    passed != nil
  end

  def failed
    return nil if passed.nil?
    passed == false
  end

  def status
    if reviewed_at.present?
      passed ? "accepted" : "rejected"
    elsif received_at.present? && expired_at.present?
      "received_and_overdue"
    elsif expired_at.present?
      "overdue"
    elsif received_at.present?
      "received"
    elsif requested_at.present?
      "waiting_on"
    else
      "not_started"
    end
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
