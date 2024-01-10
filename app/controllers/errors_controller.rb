class ErrorsController < ApplicationController
  include EligibilityCurrentNamespace

  skip_before_action :verify_authenticity_token

  def forbidden
    render "forbidden", formats: :html, status: :forbidden
  end

  def not_found
    render "not_found", formats: :html, status: :not_found
  end

  def unprocessable_entity
    render "unprocessable_entity", formats: :html, status: :unprocessable_entity
  end

  def too_many_requests
    render "too_many_requests", formats: :html, status: :too_many_requests
  end

  def internal_server_error
    render "internal_server_error",
           formats: :html,
           status: :internal_server_error
  end
end
