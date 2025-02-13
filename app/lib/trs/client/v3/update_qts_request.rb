# frozen_string_literal: true

class TRS::Client::V3::UpdateQTSRequest
  include ServicePattern
  include TRS::Client::Connection

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    path = "/v3/persons/#{trn}/professional-statuses/#{reference}"
    body = TRS::V3::QTSRequestParams.call(application_form:)
    response =
      connection.put(path) do |req|
        # TODO: Temporary API version and will need to change once in production
        req.headers["X-Api-Version"] = "Next"
        req.body = body
      end

    response.body.transform_keys { |key| key.underscore.to_sym }
  end

  private

  attr_reader :application_form

  def trn
    application_form.trn
  end

  def reference
    application_form.reference
  end
end
