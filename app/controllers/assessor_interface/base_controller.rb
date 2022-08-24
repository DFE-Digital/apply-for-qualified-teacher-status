module AssessorInterface
  class BaseController < ApplicationController
    before_action :authenticate_staff!

    def current_namespace
      "assessor"
    end
  end
end
