# frozen_string_literal: true

class ExpireRequestable
  include ServicePattern

  def initialize(requestable:, user:)
    @requestable = requestable
    @user = user
  end

  def call
    raise NotRequested unless requestable.requested?

    ActiveRecord::Base.transaction do
      requestable.expired!
      requestable.after_expired(user:)
      create_timeline_event
    end

    requestable
  end

  class NotRequested < StandardError
  end

  private

  attr_reader :requestable, :user, :force

  delegate :application_form, to: :requestable

  def create_timeline_event
    creator = user.is_a?(String) ? nil : user
    creator_name = user.is_a?(String) ? user : ""

    TimelineEvent.create!(
      application_form:,
      creator:,
      creator_name:,
      event_type: "requestable_expired",
      requestable:,
    )
  end
end
