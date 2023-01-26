# frozen_string_literal: true

class SubmitReferenceRequest
  include ServicePattern

  def initialize(reference_request:, user:)
    @reference_request = reference_request
    @user = user
  end

  def call
    raise AlreadySubmitted if reference_request.received?

    ActiveRecord::Base.transaction do
      reference_request.received!
      create_timeline_event
      ApplicationFormStatusUpdater.call(application_form:, user:)
    end
  end

  class AlreadySubmitted < StandardError
  end

  private

  attr_reader :reference_request, :user

  delegate :application_form, to: :reference_request

  def create_timeline_event
    TimelineEvent.create!(
      application_form:,
      creator_name: user,
      event_type: "requestable_received",
      requestable: reference_request,
    )
  end
end
