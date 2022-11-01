# frozen_string_literal: true

class UpdateDQTTRNRequestJob < ApplicationJob
  class StillPending < StandardError
  end

  retry_on Faraday::Error, wait: :exponentially_longer, attempts: 10
  retry_on StillPending, wait: 30.minutes, attempts: 7 * 24 * 2 # 1 week

  def perform(dqt_trn_request)
    return if dqt_trn_request.complete?

    response = fetch_response(dqt_trn_request)

    dqt_trn_request.pending! if dqt_trn_request.initial?

    if (trn = response[:trn]).present?
      update_teacher_trn(dqt_trn_request, trn)
      send_award_email(dqt_trn_request)
      update_application_form(dqt_trn_request)
      dqt_trn_request.complete!
    end

    raise StillPending if dqt_trn_request.pending?
  end

  private

  def fetch_response(dqt_trn_request)
    if dqt_trn_request.initial?
      DQT::Client::CreateTRNRequest.call(
        request_id: dqt_trn_request.request_id,
        application_form: dqt_trn_request.application_form,
      )
    else
      DQT::Client::ReadTRNRequest.call(request_id: dqt_trn_request.request_id)
    end
  end

  def update_teacher_trn(dqt_trn_request, trn)
    dqt_trn_request.application_form.teacher.update!(trn:)
  end

  def send_award_email(dqt_trn_request)
    return if dqt_trn_request.application_form.awarded?

    TeacherMailer
      .with(teacher: dqt_trn_request.application_form.teacher)
      .application_awarded
      .deliver_later
  end

  def update_application_form(dqt_trn_request)
    ChangeApplicationFormState.call(
      application_form: dqt_trn_request.application_form,
      user: "DQT",
      new_state: "awarded",
    )
  end
end
