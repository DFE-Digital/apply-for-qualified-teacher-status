# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered an error
  # Note that `retry_on` rescues the exception to reschedule the job,
  # which stops it going into Sentry until all attempts are exhausted.
  # The job then sits in the "Failed jobs" list and will need manual action.
  # 10 attempts equates to ~4 hours in total.
  retry_on StandardError, wait: :polynomially_longer, attempts: 10

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
end
