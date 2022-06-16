DfE::Analytics.configure do |config|
  config.enable_analytics =
    proc { ENV.fetch("BIGQUERY_DISABLE", "false") != "true" }
  config.queue = :analytics
  config.environment = ENV.fetch("HOSTING_ENVIRONMENT", "development")
end
