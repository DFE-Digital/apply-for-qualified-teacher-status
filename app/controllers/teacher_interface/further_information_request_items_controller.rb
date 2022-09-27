module TeacherInterface
  class FurtherInformationRequestItemsController < BaseController
    before_action :load_application_form

    def edit
      @further_information_request_item = further_information_request_item
      @further_information_request =
        further_information_request_item.further_information_request
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
  end
end
