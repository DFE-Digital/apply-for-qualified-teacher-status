# frozen_string_literal: true

class SolidQueueApplicationJob < ApplicationJob
  # Automatically retry jobs that encountered an error
  retry_on StandardError, wait: :polynomially_longer, attempts: 20

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
end
