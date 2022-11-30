# frozen_string_literal: true

module TeacherInterface
  class UploadsController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    before_action :redirect_unless_draft_or_further_information
    before_action :load_application_form
    before_action :load_document
    before_action :load_upload, only: %i[delete destroy]

    def new
      @upload_form = UploadForm.new(document:)
    end

    def create
      @upload_form = UploadForm.new(upload_form_params.merge(document:))

      handle_application_form_section(
        form: @upload_form,
        if_success_then_redirect: -> do
          history_stack.replace_self(
            path:
              edit_teacher_interface_application_form_document_path(document),
            origin: false,
            check: false,
          )
          document_path
        end,
        if_failure_then_render: :new,
      )
    end

    def delete
      @delete_upload_form = DeleteUploadForm.new
    end

    def destroy
      @delete_upload_form =
        TeacherInterface::DeleteUploadForm.new(
          confirm: params.dig(:teacher_interface_delete_upload_form, :confirm),
          upload: @upload,
        )

      if @delete_upload_form.save(validate: true)
        redirect_to document_path
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

    def document_path
      teacher_interface_application_form_document_path(
        @document,
        next: params[:next],
      )
    end
  end
end
