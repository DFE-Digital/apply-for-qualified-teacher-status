module AssessorInterface
  class ApplicationFormsController < BaseController
    def index
      @view_object = ApplicationFormsIndexViewObject.new(params:)
      render layout: "full_from_desktop"
    end

    def show
      @view_object = ApplicationFormsShowViewObject.new(params:)
    end

    def status
      @view_object = ApplicationFormsShowViewObject.new(params:)
    end
  end
end
