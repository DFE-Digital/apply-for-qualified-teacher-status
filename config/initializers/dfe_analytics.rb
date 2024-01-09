# frozen_string_literal: true

DfE::Analytics.configure do |config|
  config.entity_table_checks_enabled = Rails.env.production?
  config.environment = HostingEnvironment.name
  config.queue = :analytics

  config.enable_analytics =
    proc do
      disabled_by_default = Rails.env.development?
      ENV.fetch("BIGQUERY_DISABLE", disabled_by_default.to_s) != "true"
    end
end
