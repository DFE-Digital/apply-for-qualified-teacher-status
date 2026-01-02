# frozen_string_literal: true

module AssessorInterface
  class ApplicationFormsExportsController < BaseController
    include ActionController::Live
    include CSVStreamable

    before_action only: %i[index] do
      authorize %i[assessor_interface application_forms_export]
    end

    def index
      @view_object = ApplicationFormsIndexViewObject.new(params:, session:)

      set_csv_headers(filename: "applications-#{Time.current.iso8601}.csv")
      stream_csv(
        data: @view_object.application_forms_result,
        csv_content_class: ApplicationFormsExportContent,
      )
    end
  end
end
