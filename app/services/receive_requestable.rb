# frozen_string_literal: true

class ReceiveRequestable
  include ServicePattern

  def initialize(requestable:, user:)
    @requestable = requestable
    @user = user
  end

  def call
    raise AlreadyReceived if requestable.received?

    ActiveRecord::Base.transaction do
      requestable.received!
      create_timeline_event
      ApplicationFormStatusUpdater.call(application_form:, user:)
    end

    requestable.after_received(user:)
  end

  class AlreadyReceived < StandardError
  end

  private

  attr_reader :requestable, :user

  delegate :application_form, to: :requestable

  def create_timeline_event
    creator = user.is_a?(String) ? nil : user
    creator_name = user.is_a?(String) ? user : ""

    TimelineEvent.create!(
      application_form:,
      creator:,
      creator_name:,
      event_type: "requestable_received",
      requestable:,
    )
  end
end
