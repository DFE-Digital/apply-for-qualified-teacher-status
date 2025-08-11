# frozen_string_literal: true

# This controller is for testing Sentry integration only. Do not enable in production.
class SentryTestController < ApplicationController
  # GET /sentry_test/error
  def error
    raise "Sentry test error: This is a test exception to verify Sentry reporting."
  end
end
