module AssessorInterface
  class BaseController < ApplicationController
    def current_namespace
      "assessor"
    end
  end
end
