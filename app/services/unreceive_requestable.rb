# frozen_string_literal: true

class UnreceiveRequestable
  include ServicePattern

  def initialize(requestable:, user:)
    @requestable = requestable
    @user = user
  end

  def call
    raise NotReceived unless requestable.received?

    ActiveRecord::Base.transaction do
      requestable.update!(received_at: nil)
      delete_timeline_events
      ApplicationFormStatusUpdater.call(application_form:, user:)
    end
  end

  class NotReceived < StandardError
  end

  private

  attr_reader :requestable, :user

  delegate :application_form, to: :requestable

  def delete_timeline_events
    TimelineEvent.where(
      application_form:,
      event_type: "requestable_received",
      requestable:,
    ).delete_all
  end
end
