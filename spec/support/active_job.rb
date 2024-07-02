# frozen_string_literal: true

RSpec.configure do |config|
  config.include ActiveJob::TestHelper, type: :system

  config.around(:example, type: :system) do |example|
    perform_enqueued_jobs { example.run }
  end

  config.after(:example, type: :system) { clear_enqueued_jobs }

  # Necessary for `perform_enqueued_jobs` to work:
  # https://github.com/rails/rails/issues/37270
  (ActiveJob::Base.descendants << ActiveJob::Base).each(&:disable_test_adapter)
end
