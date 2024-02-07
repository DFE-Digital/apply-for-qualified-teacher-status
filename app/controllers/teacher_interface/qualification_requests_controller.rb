# frozen_string_literal: true

module TeacherInterface
  class QualificationRequestsController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    before_action :load_qualification_request, except: :index

    define_history_origin :index
    define_history_reset :index

    def index
      @view_object = QualificationRequestsViewObject.new(application_form:)
    end

    def edit_download
      @form =
        QualificationRequestDownloadForm.new(
          qualification_request:,
          downloaded:
            qualification_request.unsigned_consent_document_downloaded,
        )
    end

    def update_download
      @form =
        QualificationRequestDownloadForm.new(
          qualification_request:,
          downloaded:
            params.dig(
              :teacher_interface_qualification_request_download_form,
              :downloaded,
            ),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect:
          teacher_interface_application_form_qualification_requests_path,
        if_failure_then_render: :edit_download,
      )
    end

    private

    attr_reader :qualification_request

    def load_qualification_request
      @qualification_request =
        QualificationRequest
          .joins(assessment: :application_form)
          .includes(:qualification, :application_form)
          .find_by!(id: params[:id], assessment: { application_form: })

      @qualification = qualification_request.qualification
    end
  end
end
