OkComputer.mount_at = "healthcheck"

OkComputer::Registry.register "postgresql", OkComputer::ActiveRecordCheck.new
OkComputer::Registry.register "version", OkComputer::AppVersionCheck.new

OkComputer.make_optional %w[version]
