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

      CreateTimelineEvent.call(
        "requestable_received",
        application_form:,
        user:,
        requestable:,
      )

      ApplicationFormStatusUpdater.call(application_form:, user:)
    end

    requestable.after_received(user:)
  end

  class AlreadyReceived < StandardError
  end

  private

  attr_reader :requestable, :user

  delegate :application_form, to: :requestable
end
