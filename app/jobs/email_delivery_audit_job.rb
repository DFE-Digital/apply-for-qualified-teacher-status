# frozen_string_literal: true

class EmailDeliveryAuditJob < ApplicationJob
  def perform(to, subject, mailer_class_name, mailer_action_name, params = {})
    EmailDelivery.create!(
      to:,
      subject:,
      mailer_action_name:,
      mailer_class_name:,
      application_form: params[:application_form],
      further_information_request: params[:further_information_request],
      reference_request: params[:reference_request],
      prioritisation_reference_request:
        params[:prioritisation_reference_request],
    )
  end
end
