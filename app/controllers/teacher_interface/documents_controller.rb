# frozen_string_literal: true

module TeacherInterface
  class DocumentsController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    before_action :redirect_unless_draft_or_additional_information
    before_action :load_application_form
    before_action :load_document

    skip_before_action :track_history, only: :show

    def show
      if document.uploads.empty? && !document.optional?
        redirect_to [
                      :new,
                      :teacher_interface,
                      :application_form,
                      document,
                      :upload,
                    ]
      else
        redirect_to [:edit, :teacher_interface, :application_form, document]
      end
    end

    def edit
      if show_available_form?
        @form =
          DocumentAvailableForm.new(document:, available: document.available)
        render :edit_available
      else
        @form = AddAnotherUploadForm.new
        render :edit_uploads
      end
    end

    def update
      @form =
        if show_available_form?
          DocumentAvailableForm.new(
            document:,
            available:
              params.dig(
                :teacher_interface_document_available_form,
                :available,
              ),
          )
        else
          AddAnotherUploadForm.new(
            add_another:
              params.dig(
                :teacher_interface_add_another_upload_form,
                :add_another,
              ),
          )
        end

      handle_application_form_section(
        form: @form,
        if_success_then_redirect: ->(check_path) do
          if show_available_form? && @form.available
            if document.uploads.empty?
              new_teacher_interface_application_form_document_upload_path(
                document,
              )
            else
              edit_teacher_interface_application_form_document_path(document)
            end
          elsif !show_available_form? && @form.add_another
            new_teacher_interface_application_form_document_upload_path(
              document,
            )
          else
            check_path || DocumentContinueRedirection.call(document:)
          end
        end,
        if_failure_then_render:
          show_available_form? ? :edit_available : :edit_uploads,
      )
    end

    private

    def show_available_form?
      document.optional? && document.uploads.empty?
    end
  end
end
