# frozen_string_literal: true

module RescueActiveStorageErrors
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveStorage::FileNotFoundError, with: :error_not_found
    rescue_from Faraday::TimeoutError, with: :error_internal_server_error
    rescue_from IOError, with: :error_internal_server_error
  end

  def error_not_found
    render "errors/not_found", status: :not_found
  end

  def error_internal_server_error
    render "errors/internal_server_error", status: :internal_server_error
  end
end
