DfE::Analytics.configure do |config|
  config.queue = :analytics
  config.environment = ENV.fetch("SENTRY_ENVIRONMENT", "development")
end
