module ErrorLog
  class Engine < ::Rails::Engine
    isolate_namespace ErrorLog

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
