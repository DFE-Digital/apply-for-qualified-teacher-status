# frozen_string_literal: true

class ExpireFurtherInformationRequestsJob < ApplicationJob
  def perform
    FurtherInformationRequest
      .requested
      .find_each do |further_information_request|
      ExpireRequestableJob.perform_later(
        requestable: further_information_request,
      )
    end
  end
end
