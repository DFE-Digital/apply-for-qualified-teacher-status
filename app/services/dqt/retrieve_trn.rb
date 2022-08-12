module Dqt
  class RetrieveTrn
    include ServicePattern

    def initialize(trn_request_id:)
      @trn_request_id = trn_request_id
    end

    def call
      response["trn"]
    end

  private

    attr_reader :trn_request_id

    def response
      @response ||= Client.get("/v2/trn-requests/#{trn_request_id}")
    end
  end
end
