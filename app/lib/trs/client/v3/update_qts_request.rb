# frozen_string_literal: true

class TRS::Client::V3::UpdateQTSRequest
  include ServicePattern
  include TRS::Client::Connection

  def initialize(application_form:, trn:, awarded_at:)
    @application_form = application_form
    @awarded_at = awarded_at
    @trn = trn
  end

  def call
    path = "/v3/persons/#{trn}/routes-to-professional-statuses/#{reference}"
    body = TRS::V3::QTSRequestParams.call(application_form:, awarded_at:)
    response =
      connection.put(path) do |req|
        req.headers["X-Api-Version"] = "20250627"
        req.body = body
      end

    response.body
  end

  private

  attr_reader :application_form, :trn, :awarded_at

  def reference
    application_form.reference
  end
end
