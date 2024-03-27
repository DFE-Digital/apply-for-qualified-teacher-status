# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ActiveStorage::SetCurrent
  include DfE::Analytics::Requests
  include Pundit::Authorization

  append_view_path Rails.root.join("app/components")
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  layout "two_thirds"

  before_action :authenticate_support!, unless: :service_open?

  def current_user
    nil
  end

  helper_method :current_namespace

  private

  def authenticate_support!
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV.fetch("SUPPORT_USERNAME") &&
        password == ENV.fetch("SUPPORT_PASSWORD")
    end
  end

  def service_open?
    Rails.env.development? || Rails.env.test? ||
      FeatureFlags::FeatureFlag.active?(:service_open)
  end
end
