module ErrorLog
  class Engine < ::Rails::Engine
    isolate_namespace ErrorLog

    config.generators { |g| g.test_framework :rspec }
  end
end
