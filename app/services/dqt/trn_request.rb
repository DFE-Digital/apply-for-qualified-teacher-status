module Dqt
  class TrnRequest
    include ServicePattern

    def initialize(application_form:)
      @application_form = application_form
    end

    def call
      params = TrnRequestParams.new(application_form:).as_hash
      # store the request with the request id in the DB so we can poll for the TRN if needed
      request_id = SecureRandom.uuid
      path = "/v2/trn-requests/#{request_id}"
      body = params.to_json

      #handle response errors etc
      #the TRN sometimes comes back in this request but it might not, we may have to poll
      #we'll need to store the TRN somewhere too as we need that for the award request
      #https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L487-L498
      Client.put(path, body:)
    end

    private

    attr_reader :application_form
  end
end
