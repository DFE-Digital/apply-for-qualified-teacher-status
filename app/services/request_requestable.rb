# frozen_string_literal: true

class RequestRequestable
  include ServicePattern

  def initialize(requestable:, user:, allow_already_requested: false)
    @requestable = requestable
    @user = user
    @allow_already_requested = allow_already_requested
  end

  def call
    raise AlreadyRequested if !allow_already_requested && requestable.requested?

    ActiveRecord::Base.transaction do
      requestable.requested!

      requestable.update!(expired_at: nil) if requestable.expired?

      CreateTimelineEvent.call(
        "requestable_requested",
        application_form:,
        user:,
        requestable:,
      )
    end

    requestable.after_requested(user:)
  end

  class AlreadyRequested < StandardError
  end

  private

  attr_reader :requestable, :user, :allow_already_requested

  delegate :application_form, to: :requestable
end
