class ApplicationController < ActionController::Base
  default_form_builder(GOVUKDesignSystemFormBuilder::FormBuilder)

  http_basic_authenticate_with name: ENV.fetch("SUPPORT_USERNAME", "test"),
                               password: ENV.fetch("SUPPORT_PASSWORD", "test"),
                               unless: -> { FeatureFlag.active?(:service_open) }
end
