module TeacherInterface
  class UploadsController < BaseController
    before_action :load_application_form
    before_action :load_document
    before_action :load_upload, only: %i[delete destroy]

    def new
      @upload = Upload.new(document:)
    end

    def create
      if save_uploads
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
      if ActiveModel::Type::Boolean.new.cast(params.dig(:upload, :confirm))
        @upload.attachment.purge
        @upload.destroy!
      end

      redirect_to [:edit, :teacher_interface, @application_form, @document]
    end

    private

    def load_upload
      @upload = document.uploads.find(params[:id])
    end

    def save_uploads
      attachment = params.dig(:upload, :attachment)
      @upload = document.uploads.build(attachment:, translation: false)
      return unless @upload.valid?

      if (translated_attachment = params.dig(:upload, :translated_attachment))
        translated_upload =
          document.uploads.build(
            attachment: translated_attachment,
            translation: true
          )

        unless translated_upload.save
          @upload.errors[:translated_attachment] = translated_upload.errors[
            :attachment
          ]
          return
        end
      end

      @upload.save!
    end
  end
end
