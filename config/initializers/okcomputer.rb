OkComputer.mount_at = "healthcheck"

OkComputer::Registry.register "postgresql", OkComputer::ActiveRecordCheck.new

OkComputer::Registry.register "redis",
                              OkComputer::RedisCheck.new(
                                url:
                                  ENV.fetch(
                                    "REDIS_URL",
                                    "redis://localhost:6379/1"
                                  )
                              )

OkComputer::Registry.register "version", OkComputer::AppVersionCheck.new

OkComputer.make_optional %w[version]
