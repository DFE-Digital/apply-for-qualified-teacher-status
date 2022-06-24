module SupportInterface
  class BaseController < ApplicationController
    before_action :authenticate_staff!

    def current_namespace
      "support"
    end
  end
end
