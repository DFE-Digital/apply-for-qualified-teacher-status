module TeacherInterface
  class DocumentsController < BaseController
    include HandleApplicationFormSection

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
      @add_another_upload_form =
        TeacherInterface::AddAnotherUploadForm.new(
          add_another:
            params.dig(
              :teacher_interface_add_another_upload_form,
              :add_another,
            ),
        )

      handle_application_form_section(
        form: @add_another_upload_form,
        if_success_then_redirect: -> do
          if @add_another_upload_form.add_another
            new_teacher_interface_application_form_document_upload_path(
              document,
              next: params[:next],
            )
          else
            params[:next].presence ||
              DocumentContinueRedirection.call(document:)
          end
        end,
        if_failure_then_render: :edit,
      )
    end
  end
end
