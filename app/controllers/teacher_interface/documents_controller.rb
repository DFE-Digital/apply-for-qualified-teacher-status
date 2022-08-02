module TeacherInterface
  class DocumentsController < BaseController
    before_action :load_application_form
    before_action :load_document

    def edit
      if document.uploads.empty?
        redirect_to new_teacher_interface_application_form_document_upload_path(
                      @document
                    )
      end
    end

    def update
      if ActiveModel::Type::Boolean.new.cast(document_params[:add_another])
        redirect_to new_teacher_interface_application_form_document_upload_path(
                      @document
                    )
      else
        redirect_to continue_url
      end
    end

    private

    def document_params
      params.require(:document).permit(:add_another)
    end

    def continue_url
      case document.document_type
      when "name_change"
        %i[teacher_interface application_form personal_information]
      else
        %i[teacher_interface application_form]
      end
    end
  end
end
