# frozen_string_literal: true

module TeacherInterface
  class FurtherInformationRequestItemsController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    before_action :load_application_form,
                  :load_further_information_request_and_item

    def edit
      send("edit_#{further_information_request_item.information_type}")
    end

    def update
      send("update_#{further_information_request_item.information_type}")
    end

    private

    def load_further_information_request_and_item
      @further_information_request_item = further_information_request_item
      @further_information_request = further_information_request
    end

    def edit_text
      @further_information_request_item_text_form =
        FurtherInformationRequestItemTextForm.new(
          response: further_information_request_item.response,
        )
    end

    def edit_document
    end

    def update_text
      @further_information_request_item_text_form =
        FurtherInformationRequestItemTextForm.new(
          further_information_request_item_text_form_params.merge(
            further_information_request_item:,
          ),
        )

      handle_application_form_section(
        form: @further_information_request_item_text_form,
        if_success_then_redirect: [
          :teacher_interface,
          :application_form,
          further_information_request,
        ],
      )
    end

    def update_document
      if params[:button] == "save_and_continue"
        history_stack.pop
        redirect_to document_path
      else
        redirect_to further_information_request_path
      end
    end

    def further_information_request_item
      @further_information_request_item ||=
        FurtherInformationRequestItem
          .joins(further_information_request: :assessment)
          .includes(:further_information_request)
          .where(
            further_information_request: {
              id: params[:further_information_request_id],
              assessments: {
                application_form:,
              },
            },
          )
          .find(params[:id])
    end

    def further_information_request
      further_information_request_item.further_information_request
    end

    def further_information_request_item_text_form_params
      params.require(
        :teacher_interface_further_information_request_item_text_form,
      ).permit(:response)
    end

    def document_path
      teacher_interface_application_form_document_path(
        further_information_request_item.document,
      )
    end

    def further_information_request_path
      teacher_interface_application_form_further_information_request_path(
        further_information_request,
      )
    end
  end
end
