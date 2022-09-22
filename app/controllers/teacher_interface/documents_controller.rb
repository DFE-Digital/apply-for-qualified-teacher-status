module TeacherInterface
  class DocumentsController < BaseController
    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form
    before_action :load_document

    def edit
      if document.uploads.empty?
        redirect_to new_teacher_interface_application_form_document_upload_path(
                      @document,
                    )
      end
    end

    def update
      add_another = params.dig(:document, :add_another)

      if add_another && ActiveModel::Type::Boolean.new.cast(add_another)
        redirect_to new_teacher_interface_application_form_document_upload_path(
                      @document,
                    )
      else
        redirect_to document.continue_url
      end
    end
  end
end
