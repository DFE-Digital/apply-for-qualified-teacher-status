class ApplicationController < ActionController::Base
  include ActiveStorage::SetCurrent
  include DfE::Analytics::Requests

  default_form_builder(GOVUKDesignSystemFormBuilder::FormBuilder)

  before_action :authenticate, unless: -> { FeatureFlag.active?(:service_open) }

  def current_user
    nil
  end

  helper_method :current_namespace

  private

  def authenticate
    valid_credentials = [
      {
        username: ENV.fetch("SUPPORT_USERNAME", "support"),
        password: ENV.fetch("SUPPORT_PASSWORD", "support")
      }
    ]

    if FeatureFlag.active?(:staff_test_user)
      valid_credentials.push(
        {
          username: ENV.fetch("TEST_USERNAME", "test"),
          password: ENV.fetch("TEST_PASSWORD", "test")
        }
      )
    end

    authenticate_or_request_with_http_basic do |username, password|
      valid_credentials.include?({ username:, password: })
    end
  end
end
