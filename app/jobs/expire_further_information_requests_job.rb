# frozen_string_literal: true

class ExpireFurtherInformationRequestsJob < ApplicationJob
  def perform
    FurtherInformationRequest
      .requested
      .find_each do |further_information_request|
      ExpireFurtherInformationRequestJob.perform_later(
        further_information_request:,
      )
    end
  end
end
