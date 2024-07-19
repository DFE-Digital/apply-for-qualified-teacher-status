# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class EditSuitabilityRecord < SuitabilityRecordFormPage
      set_url "/assessor/suitability-records/{id}/edit"

      element :heading, "h1"
    end
  end
end
