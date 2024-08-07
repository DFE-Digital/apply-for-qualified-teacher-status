# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class CreateSuitabilityRecord < SuitabilityRecordFormPage
      set_url "/assessor/suitability-records/new"

      element :heading, "h1"
    end
  end
end
