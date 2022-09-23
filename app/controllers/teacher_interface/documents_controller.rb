module TeacherInterface
  class DocumentsController < BaseController
    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form
    before_action :load_document

    def edit
      @add_another_upload_form = AddAnotherUploadForm.new
      if document.uploads.empty?
        redirect_to new_teacher_interface_application_form_document_upload_path(
                      @document,
                    )
      end
    end

    def update
      add_another =
        params.dig(:teacher_interface_add_another_upload_form, :add_another)
      @add_another_upload_form =
        TeacherInterface::AddAnotherUploadForm.new(add_another:)
      if @add_another_upload_form.valid?
        if @add_another_upload_form.add_another
          redirect_to new_teacher_interface_application_form_document_upload_path(
                        @document,
                      )
        else
          redirect_to document.continue_url
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end
end
