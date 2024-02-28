# frozen_string_literal: true

module Requestable
  extend ActiveSupport::Concern

  include Expirable

  included do
    belongs_to :assessment

    scope :requested, -> { where.not(requested_at: nil) }
    scope :received, -> { where.not(received_at: nil) }
    scope :not_received, -> { where(received_at: nil) }
    scope :respondable,
          -> { requested.not_received.merge(ApplicationForm.assessable) }
    scope :verified, -> { where.not(verified_at: nil) }

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

  def reviewed?
    review_passed != nil
  end

  def review_passed?
    review_passed == true
  end

  def review_failed?
    review_passed == false
  end

  def verified?
    try(:verify_passed) != nil
  end

  def verify_passed?
    try(:verify_passed) == true
  end

  def verify_failed?
    try(:verify_passed) == false
  end

  def status(not_requested: "not_started")
    if review_passed? || review_failed?
      review_status
    elsif verify_passed?
      "accepted"
    elsif verify_failed?
      "review"
    elsif received? && expired?
      "received_and_overdue"
    elsif expired?
      "overdue"
    elsif received?
      "received"
    elsif requested?
      "waiting_on"
    else
      not_requested
    end
  end

  def review_status
    if review_passed?
      "accepted"
    elsif review_failed?
      "rejected"
    else
      "not_started"
    end
  end

  def verify_status
    if verify_passed?
      "accepted"
    elsif verify_failed?
      "rejected"
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

  def after_verified(user:)
    # implement logic after this requestable has been verified
  end
end
