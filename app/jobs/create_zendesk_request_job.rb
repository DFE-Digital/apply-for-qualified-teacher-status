# frozen_string_literal: true

class CreateZendeskRequestJob < ApplicationJob
  def perform(support_request)
    response =
      Zendesk.create_request!(
        name: support_request.name,
        email: support_request.email,
        subject: subject(support_request),
        comment: support_request.comment,
      )

    support_request.update!(
      zendesk_ticket_id: response.id,
      zendesk_ticket_created_at: response.created_at,
    )
  end

  private

  def submitting_an_application_user?(support_request)
    support_request.user_type == "submitting_an_application"
  end

  def application_progress_update_enquiry?(support_request)
    support_request.application_enquiry_type == "progress_update"
  end

  def subject(support_request)
    subject_prefix =
      if application_progress_update_enquiry?(support_request) ||
           submitting_an_application_user?(support_request)
        "[AfQTS Ops]"
      else
        "[AfQTS PR]"
      end

    if support_request.application_reference.present?
      "#{subject_prefix} Support request for #{support_request.application_reference}"
    else
      "#{subject_prefix} Support request"
    end
  end
end
