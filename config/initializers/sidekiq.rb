# frozen_string_literal: true

url = ENV.fetch("REDIS_URL", "redis://localhost:6379/1")

Sidekiq.configure_server do |config|
  config.redis = { url: }
  config.logger.level = Logger::WARN
end

Sidekiq.configure_client { |config| config.redis = { url: } }
