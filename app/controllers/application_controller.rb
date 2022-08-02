class ApplicationController < ActionController::Base
  include DfE::Analytics::Requests

  default_form_builder(GOVUKDesignSystemFormBuilder::FormBuilder)
  before_action :authenticate_staff!,
                unless: -> { FeatureFlag.active?(:service_open) }

  def current_user
    nil
  end

  helper_method :current_namespace
end
