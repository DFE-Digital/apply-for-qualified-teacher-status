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
      create_timeline_event
      ApplicationFormStatusUpdater.call(application_form:, user:)
    end

    requestable.after_requested(user:)
  end

  class AlreadyRequested < StandardError
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
      event_type: "requestable_requested",
      requestable:,
    )
  end
end
