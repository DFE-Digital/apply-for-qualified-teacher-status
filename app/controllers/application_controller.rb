class ApplicationController < ActionController::Base
  include DfE::Analytics::Requests

  default_form_builder(GOVUKDesignSystemFormBuilder::FormBuilder)

  def current_user
    nil
  end

  helper_method :current_namespace
end
