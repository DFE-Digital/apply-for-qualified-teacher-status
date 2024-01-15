# frozen_string_literal: true

class RequestRequestable
  include ServicePattern

  def initialize(requestable:, user:)
    @requestable = requestable
    @user = user
  end

  def call
    raise AlreadyRequested if requestable.requested?

    ActiveRecord::Base.transaction do
      requestable.requested!

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

  attr_reader :requestable, :user

  delegate :application_form, to: :requestable
end
