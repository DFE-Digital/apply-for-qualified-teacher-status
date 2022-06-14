module SupportInterface
  class BaseController < ApplicationController
    http_basic_authenticate_with name: ENV.fetch("SUPPORT_USERNAME", "test"),
                                 password: ENV.fetch("SUPPORT_PASSWORD", "test")

    def current_namespace
      "support"
    end
  end
end
