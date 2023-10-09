# frozen_string_literal: true

module Requestable
  extend ActiveSupport::Concern

  include Expirable

  included do
    belongs_to :assessment

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

  def status
    if verify_passed? || review_passed?
      "completed"
    elsif review_failed?
      "rejected"
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
      "not_started"
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
