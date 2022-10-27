# frozen_string_literal: true

class CreateDQTTRNRequestJob < ApplicationJob
  def perform(request_id, application_form)
    CreateDQTTRNRequest.call(request_id:, application_form:)
  end
end
