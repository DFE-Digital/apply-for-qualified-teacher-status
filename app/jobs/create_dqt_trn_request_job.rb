# frozen_string_literal: true

class CreateDQTTRNRequestJob < ApplicationJob
  def perform(application_form)
    CreateDQTTRNRequest.call(application_form:)
  end
end
