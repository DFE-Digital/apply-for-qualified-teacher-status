module TeacherInterface
  class FurtherInformationRequestItemsController < BaseController
    before_action :load_application_form

    def edit
      @further_information_request_item = further_information_request_item
      @further_information_request = further_information_request
    end

    def update
      if params[:next] == "save_and_continue"
        redirect_to [
                      :edit,
                      :teacher_interface,
                      :application_form,
                      further_information_request_item.document,
                    ]
      else
        redirect_to [
                      :teacher_interface,
                      :application_form,
                      further_information_request,
                    ]
      end
    end

    private

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
      @further_information_request =
        further_information_request_item.further_information_request
    end
  end
end
