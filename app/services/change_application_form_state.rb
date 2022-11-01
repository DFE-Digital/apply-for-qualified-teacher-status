# frozen_string_literal: true

class ChangeApplicationFormState
  include ServicePattern

  def initialize(application_form:, user:, new_state:)
    @application_form = application_form
    @user = user
    @new_state = new_state
  end

  def call
    return if application_form.state == new_state

    old_state = application_form.state

    ActiveRecord::Base.transaction do
      application_form.update!(state: new_state)
      create_timeline_event(old_state:)
    end
  end

  private

  attr_reader :application_form, :user, :new_state

  def create_timeline_event(old_state:)
    creator = user.is_a?(String) ? nil : user
    creator_name = user.is_a?(String) ? user : ""

    TimelineEvent.create!(
      application_form:,
      event_type: "state_changed",
      creator:,
      creator_name:,
      new_state:,
      old_state:,
    )
  end
end
