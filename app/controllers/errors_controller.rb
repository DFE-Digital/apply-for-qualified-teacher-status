# frozen_string_literal: true

class ErrorsController < ApplicationController
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

  def current_namespace
    path = request.original_fullpath
    if path.starts_with?("/assessor")
      "assessor"
    elsif path.starts_with?("/support")
      "support"
    elsif path.starts_with?("/teacher")
      "teacher"
    else
      "eligibility"
    end
  end
end
