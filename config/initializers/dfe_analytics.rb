DfE::Analytics.configure do |config|
  config.enable_analytics =
    proc { ENV.fetch("BIGQUERY_DISABLE", "false") != "false" }
  config.queue = :analytics
  config.environment = ENV.fetch("SENTRY_ENVIRONMENT", "development")
end
