# frozen_string_literal: true

module TeacherInterface
  class ConsentRequestsController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    before_action :load_consent_request, only: %i[edit_download update_download]

    define_history_check :check
    define_history_origin :index
    define_history_reset :index

    def index
      @view_object = ConsentRequestsViewObject.new(application_form:)
    end

    def check
      @view_object = ConsentRequestsViewObject.new(application_form:)
    end

    def submit
      ActiveRecord::Base.transaction do
        application_form.assessment.consent_requests.each do |requestable|
          ReceiveRequestable.call(requestable:, user: current_teacher)
        end
      end

      TeacherMailer.with(application_form:).consent_submitted.deliver_later

      redirect_to %i[teacher_interface application_form]
    end

    def edit_download
      @form =
        DownloadUnsignedConsentDocumentForm.new(
          consent_request:,
          downloaded: consent_request.unsigned_document_downloaded,
        )
    end

    def update_download
      @form =
        DownloadUnsignedConsentDocumentForm.new(
          consent_request:,
          downloaded:
            params.dig(
              :teacher_interface_download_unsigned_consent_document_form,
              :downloaded,
            ),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect:
          teacher_interface_application_form_consent_requests_path,
        if_failure_then_render: :edit_download,
      )
    end

    private

    attr_reader :consent_request

    def load_consent_request
      @consent_request =
        ConsentRequest
          .joins(assessment: :application_form)
          .includes(:qualification, :application_form)
          .find_by!(id: params[:id], assessment: { application_form: })

      @qualification = consent_request.qualification
    end
  end
end
