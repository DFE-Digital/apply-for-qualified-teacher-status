# frozen_string_literal: true

module TeacherInterface
  class UploadsController < BaseController
    include ActiveStorage::Streaming
    include HandleApplicationFormSection
    include HistoryTrackable
    include StreamedResponseAuthenticatable
    include RescueActiveStorageErrors
    include UploadHelper

    skip_before_action :authenticate_teacher!
    before_action -> { authenticate_or_redirect(:teacher) }

    before_action :redirect_unless_draft_or_additional_information
    before_action :load_application_form
    before_action :load_document
    before_action :load_upload, only: %i[delete destroy show]

    def show
      if upload_downloadable?(@upload)
        send_blob_stream(@upload.attachment, disposition: :inline)
      else
        render "shared/malware_scan"
      end
    end

    def new
      @form = UploadForm.new(document:)
    end

    def create
      @form = UploadForm.new(upload_form_params.merge(document:))

      handle_application_form_section(
        form: @form,
        if_success_then_redirect: ->(_check_path) do
          history_stack.replace_self(
            path:
              edit_teacher_interface_application_form_document_path(document),
            origin: false,
            check: false,
          )

          [:teacher_interface, :application_form, document]
        end,
        if_failure_then_render: :new,
      )
    end

    def delete
      @form = DeleteUploadForm.new
    end

    def destroy
      @form =
        TeacherInterface::DeleteUploadForm.new(
          confirm: params.dig(:teacher_interface_delete_upload_form, :confirm),
          upload: @upload,
        )

      if @form.save(validate: true)
        redirect_to [:teacher_interface, :application_form, document]
      else
        render :delete, status: :unprocessable_entity
      end
    end

    private

    def load_upload
      @upload = document.uploads.find(params[:id])
    end

    def upload_form_params
      params.permit(
        teacher_interface_upload_form: %i[
          original_attachment
          translated_attachment
          written_in_english
        ],
      )[
        :teacher_interface_upload_form
      ] || {}
    end
  end
end
