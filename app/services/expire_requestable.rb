# frozen_string_literal: true

class ExpireRequestable
  include ServicePattern

  def initialize(requestable:)
    @requestable = requestable
  end

  def call
    if expire_request?
      ActiveRecord::Base.transaction do
        requestable.expired!
        requestable.after_expired(user: "Expirer")
        create_timeline_event
      end
    end

    requestable
  end

  private

  attr_reader :requestable

  delegate :application_form, to: :requestable

  def expire_request?
    return false if requestable.expired_at.blank?

    requestable.requested? && Time.zone.now >= requestable.expired_at
  end

  def create_timeline_event
    TimelineEvent.create!(
      application_form:,
      creator_name: "Expirer",
      event_type: "requestable_expired",
      requestable:,
    )
  end
end
