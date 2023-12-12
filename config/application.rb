require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require "./app/lib/hosting_environment"

module ApplyForQualifiedTeacherStatus
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"

    config.eager_load_paths << "#{root}/app/policies"

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.exceptions_app = routes

    config.assets.paths +=
      %w[
        node_modules/govuk-frontend/dist/govuk/assets
        node_modules/govuk-frontend/dist/govuk/assets/images
        node_modules/govuk-frontend/dist/govuk/assets/fonts
      ].map { |path| Rails.root.join(path) }

    config.action_dispatch.rescue_responses[
      "Pundit::NotAuthorizedError"
    ] = :forbidden
    config.action_mailer.deliver_later_queue_name = "mailer"

    config.dqt = config_for(:dqt)
  end
end
