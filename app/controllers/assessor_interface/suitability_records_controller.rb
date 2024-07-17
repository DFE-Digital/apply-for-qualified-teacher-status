# frozen_string_literal: true

require "pagy/extras/array"

module AssessorInterface
  class SuitabilityRecordsController < BaseController
    include Pagy::Backend

    def index
      authorize %i[assessor_interface suitability_record]

      @pagy, @records =
        pagy_array(
          SuitabilityRecord.includes(
            :names,
            :emails,
            :application_forms,
          ).sort_by(&:name),
        )
    end
  end
end
