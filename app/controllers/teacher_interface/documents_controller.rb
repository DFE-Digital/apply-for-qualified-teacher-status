# frozen_string_literal: true

module TeacherInterface
  class DocumentsController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    before_action :redirect_unless_draft_or_further_information
    before_action :load_application_form
    before_action :load_document

    skip_before_action :push_self, only: :show

    def show
      if document.uploads.empty?
        redirect_to new_teacher_interface_application_form_document_upload_path(
                      document,
                    )
      else
        redirect_to edit_teacher_interface_application_form_document_path(
                      document,
                    )
      end
    end

    def edit
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
        if_success_then_redirect: ->(check_path) do
          if @add_another_upload_form.add_another
            new_teacher_interface_application_form_document_upload_path(
              document,
            )
          else
            check_path || DocumentContinueRedirection.call(document:)
          end
        end,
      )
    end
  end
end
