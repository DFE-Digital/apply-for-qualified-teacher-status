# frozen_string_literal: true

class CreateTimelineEvent
  include ServicePattern

  def initialize(event_type, application_form:, user:, **kwargs)
    @event_type = event_type
    @application_form = application_form
    @user = user
    @kwargs = kwargs
  end

  def call
    creator = user.is_a?(String) ? nil : user
    creator_name = user.is_a?(String) ? user : ""

    TimelineEvent.create!(
      application_form:,
      event_type:,
      creator:,
      creator_name:,
      **kwargs,
    )
  end

  private

  attr_reader :application_form, :user, :event_type, :kwargs
end
