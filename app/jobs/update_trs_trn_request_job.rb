# frozen_string_literal: true

class UpdateTRSTRNRequestJob < ApplicationJob
  def perform(trs_trn_request)
    return if trs_trn_request.complete?

    application_form = trs_trn_request.application_form

    trn_response = fetch_trn_response(trs_trn_request)

    trs_trn_request.pending! if trs_trn_request.initial?

    potential_duplicate =
      trn_response[:potential_duplicate] && trn_response[:trn].presence.nil?

    if potential_duplicate != trs_trn_request.potential_duplicate
      trs_trn_request.update!(potential_duplicate:)
    end

    ApplicationFormStatusUpdater.call(application_form:, user: "TRS")

    unless potential_duplicate
      awarded_at = Time.zone.now

      update_qts_status_response(
        trs_trn_request.application_form,
        trn_response,
        awarded_at,
      )

      AwardQTS.call(
        application_form:,
        user: "TRS",
        trn: trn_response[:trn],
        access_your_teaching_qualifications_url:
          trn_response[:access_your_teaching_qualifications_link],
        awarded_at: awarded_at,
      )

      trs_trn_request.complete!
    end

    if trs_trn_request.pending?
      UpdateTRSTRNRequestJob.set(wait: 5.minutes).perform_later(trs_trn_request)
    end
  end

  private

  def fetch_trn_response(trs_trn_request)
    if trs_trn_request.initial?
      TRS::Client::V3::CreateTRNRequest.call(
        request_id: trs_trn_request.request_id,
        application_form: trs_trn_request.application_form,
      )
    else
      TRS::Client::V3::ReadTRNRequest.call(
        request_id: trs_trn_request.request_id,
      )
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

  def update_qts_status_response(application_form, trn_response, awarded_at)
    TRS::Client::V3::UpdateQTSRequest.call(
      application_form: application_form,
      trn: trn_response[:trn],
      awarded_at: awarded_at,
    )
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
