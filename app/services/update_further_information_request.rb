# frozen_string_literal: true

class UpdateFurtherInformationRequest
  include ServicePattern

  def initialize(further_information_request:, user:, params:)
    @further_information_request = further_information_request
    @user = user
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      further_information_request.update!(params)
      create_timeline_event
    end
  end

  private

  attr_reader :further_information_request, :user, :params

  def create_timeline_event
    unless further_information_request.passed.nil?
      TimelineEvent.create!(
        creator: user,
        event_type: "requestable_assessed",
        requestable: further_information_request,
        application_form:,
      )
    end
  end

  def application_form
    further_information_request.assessment.application_form
  end
end
