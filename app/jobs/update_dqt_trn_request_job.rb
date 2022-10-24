# frozen_string_literal: true

class UpdateDQTTRNRequestJob < ApplicationJob
  class StillPending < StandardError
  end

  retry_on StillPending, wait: 30.minutes, attempts: 7 * 24 * 2 # 1 week

  def perform(dqt_trn_request)
    return unless dqt_trn_request.pending?

    UpdateDQTTRNRequest.call(dqt_trn_request:)

    raise StillPending if dqt_trn_request.pending?
  end
end
