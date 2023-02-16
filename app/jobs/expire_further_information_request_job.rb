# frozen_string_literal: true

class ExpireFurtherInformationRequestJob < ApplicationJob
  def perform(further_information_request:)
    ExpireRequestable.call(requestable: further_information_request)
  end
end
