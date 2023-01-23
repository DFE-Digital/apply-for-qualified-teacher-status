# frozen_string_literal: true

class UpdateDQTTRNRequestJob < ApplicationJob
  sidekiq_options retry: 10

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

    potential_duplicate = response[:potential_duplicate]
    if potential_duplicate != dqt_trn_request.potential_duplicate
      dqt_trn_request.update!(potential_duplicate:)
    end

    if potential_duplicate
      ChangeApplicationFormState.call(
        application_form:,
        user: "DQT",
        new_state: "potential_duplicate_in_dqt",
      )
    else
      AwardQTS.call(application_form:, user: "DQT", trn: response[:trn])
      dqt_trn_request.complete!
    end

    if dqt_trn_request.pending?
      UpdateDQTTRNRequestJob.set(wait: 1.hour).perform_later(dqt_trn_request)
    end
  end
end
