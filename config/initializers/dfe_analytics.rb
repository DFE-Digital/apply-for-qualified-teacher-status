DfE::Analytics.configure do |config|
  config.queue = :analytics
  config.environment = HostingEnvironment.name

  config.enable_analytics =
    proc do
      disabled_by_default = Rails.env.development?
      ENV.fetch("BIGQUERY_DISABLE", disabled_by_default.to_s) != "true"
    end
end
