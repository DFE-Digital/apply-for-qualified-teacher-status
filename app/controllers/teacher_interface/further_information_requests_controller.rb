module TeacherInterface
  class FurtherInformationRequestsController < BaseController
    def show
      @view_object =
        FurtherInformationRequestViewObject.new(current_teacher:, params:)
    end
  end
end
