# frozen_string_literal: true

class UpdateTRSTRNRequestJob < ApplicationJob
  def perform(dqt_trn_request)
    return if dqt_trn_request.complete?

    application_form = dqt_trn_request.application_form

    response = fetch_response(dqt_trn_request)

    dqt_trn_request.pending! if dqt_trn_request.initial?

    potential_duplicate = response[:potential_duplicate]
    if potential_duplicate != dqt_trn_request.potential_duplicate
      dqt_trn_request.update!(potential_duplicate:)
    end

    ApplicationFormStatusUpdater.call(application_form:, user: "DQT")

    unless potential_duplicate
      AwardQTS.call(
        application_form:,
        user: "DQT",
        trn: response[:trn],
        access_your_teaching_qualifications_url:
          response[:access_your_teaching_qualifications_link],
      )
      dqt_trn_request.complete!
    end

    if dqt_trn_request.pending?
      UpdateTRSTRNRequestJob.set(wait: 1.hour).perform_later(dqt_trn_request)
    end
  end

  private

  def fetch_response(dqt_trn_request)
    if dqt_trn_request.initial?
      TRS::Client::CreateTRNRequest.call(
        request_id: dqt_trn_request.request_id,
        application_form: dqt_trn_request.application_form,
      )
    else
      TRS::Client::ReadTRNRequest.call(request_id: dqt_trn_request.request_id)
    end
  rescue Faraday::Error => e
    Sentry.configure_scope do |scope|
      scope.set_context(
        "response",
        {
          status: e.response_status,
          headers: e.response_headers,
          body: e.response_body,
        },
      )
    end

    raise
  end
end
