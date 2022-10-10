module TeacherInterface
  class FurtherInformationRequestsController < BaseController
    before_action :load_view_object

    def show
    end

    def edit
    end

    private

    def load_view_object
      @view_object =
        FurtherInformationRequestViewObject.new(current_teacher:, params:)
    end
  end
end
