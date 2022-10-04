module TeacherInterface
  class FurtherInformationRequestItemsController < BaseController
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

      if params[:next] == "save_and_continue"
        if @further_information_request_item_text_form.save(validate: true)
          redirect_to_further_information_request
        else
          render :edit, status: :unprocessable_entity
        end
      else
        @further_information_request_item_text_form.update_model
        redirect_to_further_information_request
      end
    end

    def update_document
      if params[:next] == "save_and_continue"
        redirect_to_document
      else
        redirect_to_further_information_request
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

    def redirect_to_further_information_request
      redirect_to [
                    :teacher_interface,
                    :application_form,
                    further_information_request,
                  ]
    end

    def redirect_to_document
      redirect_to [
                    :edit,
                    :teacher_interface,
                    :application_form,
                    further_information_request_item.document,
                  ]
    end
  end
end
