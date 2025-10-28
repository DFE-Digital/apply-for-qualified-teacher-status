# frozen_string_literal: true

class TestSentryController < ApplicationController
  def error
    raise 'This is a test error for Sentry integration'
  end
end
