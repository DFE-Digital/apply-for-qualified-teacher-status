class ApplicationController < ActionController::Base
  include DfE::Analytics::Requests

  default_form_builder(GOVUKDesignSystemFormBuilder::FormBuilder)

  http_basic_authenticate_with name: ENV.fetch("SUPPORT_USERNAME", "test"),
                               password: ENV.fetch("SUPPORT_PASSWORD", "test"),
                               unless: -> { FeatureFlag.active?(:service_open) }

  def current_user
    nil
  end

  helper_method :current_namespace
end
