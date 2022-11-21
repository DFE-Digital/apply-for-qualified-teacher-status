# frozen_string_literal: true

class ExpireFurtherInformationRequestJob < ApplicationJob
  def perform(further_information_request:)
    FurtherInformationRequestExpirer.call(further_information_request:)
  end
end
