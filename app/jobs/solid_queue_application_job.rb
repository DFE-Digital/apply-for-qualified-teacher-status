# frozen_string_literal: true

# TODO: Temporarily having a Solid Queue specific ApplicationJob
# Once we have fully moved all of our jobs to Solid Queue,
# this can be renamed to ApplicationJob with the self.queue_adapter removed
# since it will be set in production.rb
class SolidQueueApplicationJob < ApplicationJob
  self.queue_adapter = :solid_queue unless Rails.env.test?

  # Automatically retry jobs that encountered an error
  # Note that `retry_on` rescues the exception to reschedule the job,
  # which stops it going into Sentry until all attempts are exhausted.
  # The job then sits in the "Failed jobs" list and will need manual action.
  # 10 attempts equates to ~4 hours in total.
  retry_on StandardError, wait: :polynomially_longer, attempts: 10

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
end
