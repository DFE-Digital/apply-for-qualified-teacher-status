# frozen_string_literal: true

url = ENV.fetch("REDIS_URL", "redis://localhost:6379/1")

Sidekiq.configure_server { |config| config.redis = { url: } }

Sidekiq.configure_client { |config| config.redis = { url: } }
