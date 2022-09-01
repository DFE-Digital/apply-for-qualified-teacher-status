module AssessorInterface
  class ApplicationFormsController < BaseController
    def index
      @view_object = ApplicationFormsIndexViewObject.new(params:)
    end

    def show
      @view_object = ApplicationFormsShowViewObject.new(params:)
    end
  end
end
