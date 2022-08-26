module AssessorInterface
  class ApplicationFormsController < BaseController
    def index
      @view_object = ApplicationFormsIndexViewObject.new(params:)
    end

    def show
      @application_form = ApplicationForm.find(params[:id])
    end
  end
end
