# frozen_string_literal: true

OkComputer.mount_at = "healthcheck"

OkComputer::Registry.register "postgresql", OkComputer::ActiveRecordCheck.new

Sidekiq.redis do |conn|
  OkComputer::Registry.register "sidekiq",
                                OkComputer::RedisCheck.new(conn.connection)
end

OkComputer::Registry.register "version", OkComputer::AppVersionCheck.new

OkComputer.make_optional %w[version]
