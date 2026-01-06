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

      ExportAudit.create!(
        export_type: :application_forms,
        exported_by: current_staff,
        filter_params: (session[:filter_params] || {}).with_indifferent_access,
      )

      set_csv_headers(filename: "applications-#{Time.current.iso8601}.csv")
      stream_csv(
        data: @view_object.application_forms_result,
        csv_content_class: ApplicationFormsExportContent,
      )
    end
  end
end
