# frozen_string_literal: true

module AssessorInterface
  class SuitabilityRecordsController < BaseController
    def index
      authorize %i[assessor_interface suitability_record]
    end
  end
end
