module TeacherInterface
  class FurtherInformationRequestItemsController < BaseController
    include HandleApplicationFormSection

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
        if_success_then_redirect: further_information_request_redirection,
        if_failure_then_render: :edit,
      )
    end

    def update_document
      if params[:next] == "save_and_continue"
        redirect_to document_redirection
      else
        redirect_to further_information_request_redirection
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

    def further_information_request_redirection
      [:teacher_interface, :application_form, further_information_request]
    end

    def document_redirection
      [
        :edit,
        :teacher_interface,
        :application_form,
        further_information_request_item.document,
      ]
    end
  end
end
