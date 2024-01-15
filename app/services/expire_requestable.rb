# frozen_string_literal: true

class ExpireRequestable
  include ServicePattern

  def initialize(requestable:, user:)
    @requestable = requestable
    @user = user
  end

  def call
    raise InvalidState if invalid_state?

    ActiveRecord::Base.transaction do
      requestable.expired!
      requestable.after_expired(user:)

      CreateTimelineEvent.call(
        "requestable_expired",
        application_form:,
        user:,
        requestable:,
      )

      ApplicationFormStatusUpdater.call(user:, application_form:)
    end

    requestable
  end

  class InvalidState < StandardError
  end

  private

  attr_reader :requestable, :user, :force

  delegate :application_form, to: :requestable

  def invalid_state?
    requestable.expired? || requestable.received? || !requestable.requested?
  end
end
