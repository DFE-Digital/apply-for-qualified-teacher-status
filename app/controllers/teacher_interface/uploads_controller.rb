module TeacherInterface
  class UploadsController < BaseController
    before_action :load_application_form
    before_action :load_document
    before_action :load_upload, only: %i[delete destroy]

    def new
      @upload = Upload.new(document:)
    end

    def create
      attachment = params.dig(:upload, :attachment)
      @upload = document.uploads.build(attachment:, translation: false)
      if @upload.save
        redirect_to_if_save_and_continue [
                                           :edit,
                                           :teacher_interface,
                                           @application_form,
                                           @document
                                         ]
      else
        render :new, status: :unprocessable_entity
      end
    end

    def delete
    end

    def destroy
      @upload.attachment.purge
      @upload.destroy!
      redirect_to [:edit, :teacher_interface, @application_form, @document]
    end

    private

    def load_upload
      @upload = document.uploads.find(params[:id])
    end
  end
end
