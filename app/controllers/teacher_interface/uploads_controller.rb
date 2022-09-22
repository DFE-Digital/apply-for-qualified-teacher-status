module TeacherInterface
  class UploadsController < BaseController
    before_action :redirect_unless_application_form_is_draft
    before_action :load_application_form
    before_action :load_document
    before_action :load_upload, only: %i[delete destroy]

    def new
      @upload_form = UploadForm.new(document:)
    end

    def create
      @upload_form = UploadForm.new(upload_form_params.merge(document:))
      if @upload_form.save
        redirect_to_if_save_and_continue [
                                           :edit,
                                           :teacher_interface,
                                           :application_form,
                                           @document,
                                         ]
      elsif @upload_form.blank?
        redirect_to_if_save_and_continue document.continue_url
      else
        render :new, status: :unprocessable_entity
      end
    end

    def delete
    end

    def destroy
      if ActiveModel::Type::Boolean.new.cast(params.dig(:upload, :confirm))
        @upload.attachment.purge
        @upload.destroy!
      end

      redirect_to [:edit, :teacher_interface, :application_form, @document]
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
        ],
      )[
        :teacher_interface_upload_form
      ] || {}
    end
  end
end
