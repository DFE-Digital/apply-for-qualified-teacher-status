module TeacherInterface
  class DocumentsController < BaseController
    before_action :redirect_unless_draft_or_further_information
    before_action :load_application_form
    before_action :load_document

    def edit
      if document.uploads.empty?
        redirect_to new_teacher_interface_application_form_document_upload_path(
                      document,
                    )
      end

      @add_another_upload_form = AddAnotherUploadForm.new
    end

    def update
      add_another =
        params.dig(:teacher_interface_add_another_upload_form, :add_another)
      @add_another_upload_form =
        TeacherInterface::AddAnotherUploadForm.new(add_another:)
      if @add_another_upload_form.valid?
        if @add_another_upload_form.add_another
          redirect_to new_teacher_interface_application_form_document_upload_path(
                        document,
                      )
        else
          redirect_to DocumentContinueRedirection.call(document:)
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end
end
