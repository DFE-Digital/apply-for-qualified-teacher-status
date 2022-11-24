# frozen_string_literal: true

module AssessorInterface
  class ApplicationFormsController < BaseController
    before_action :authorize_assessor, except: :status

    def index
      @view_object = ApplicationFormsIndexViewObject.new(params:)
      render layout: "full_from_desktop"
    end

    def show
      @view_object = ApplicationFormsShowViewObject.new(params:)
    end

    def status
      authorize :assessor, :show?
      @view_object = ApplicationFormsShowViewObject.new(params:)
    end
  end
end
