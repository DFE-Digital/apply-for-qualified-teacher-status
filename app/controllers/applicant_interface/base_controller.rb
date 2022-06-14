module ApplicantInterface
  class BaseController < ApplicationController
    def current_namespace
      "applicant"
    end
  end
end
