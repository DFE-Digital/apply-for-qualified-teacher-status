# frozen_string_literal: true

class ExpireReferenceRequestsJob < ApplicationJob
  def perform
    ReferenceRequest.requested.find_each do |reference_request|
      ExpireRequestableJob.perform_later(requestable: reference_request)
    end
  end
end
