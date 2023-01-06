# frozen_string_literal: true

class UpdateDQTTRNRequestJob < ApplicationJob
  class StillPending < StandardError
  end

  sidekiq_options retry: false
  retry_on Faraday::Error, wait: :exponentially_longer, attempts: 3
  retry_on StillPending, wait: 30.minutes, attempts: 7 * 24 * 2 # 1 week

  def perform(dqt_trn_request)
    return if dqt_trn_request.complete?

    application_form = dqt_trn_request.application_form

    response =
      if dqt_trn_request.initial?
        DQT::Client::CreateTRNRequest.call(
          request_id: dqt_trn_request.request_id,
          application_form:,
        )
      else
        DQT::Client::ReadTRNRequest.call(request_id: dqt_trn_request.request_id)
      end

    dqt_trn_request.pending! if dqt_trn_request.initial?

    if response[:potential_duplicate]
      ChangeApplicationFormState.call(
        application_form:,
        user: "DQT",
        new_state: "potential_duplicate_in_dqt",
      )
    else
      AwardQTS.call(application_form:, user: "DQT", trn: response[:trn])
      dqt_trn_request.complete!
    end

    raise StillPending if dqt_trn_request.pending?
  end
end
