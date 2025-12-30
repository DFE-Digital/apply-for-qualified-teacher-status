# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.7"

gem "rails", "~> 8.0"

gem "activerecord-session_store"
gem "amazing_print"
gem "azure-storage-blob"
gem "bootsnap", require: false
gem "business"
gem "combine_pdf"
gem "cssbundling-rails"
gem "devise"
gem "devise_invitable"
gem "devise-passwordless"
gem "email_address"
gem "faraday"
gem "indefinite_article"
gem "jsbundling-rails"
gem "libreconv"
gem "matrix"
gem "okcomputer"
gem "omniauth-entra-id"
gem "omniauth_openid_connect"
gem "omniauth-rails_csrf_protection"
gem "pagy"
gem "pg"
gem "prawn"
gem "propshaft"
gem "puma"
gem "pundit"
gem "rack-attack"
gem "rails_semantic_logger"
gem "rmagick"
gem "ruby-progressbar"
gem "ruby-vips"
gem "sentry-rails"
gem "sentry-ruby"
gem "sidekiq", "<7"
gem "sidekiq-cron"
gem "sitemap_generator"
gem "validate_url"

gem "dfe-analytics", github: "DFE-Digital/dfe-analytics"
gem "dfe-autocomplete", github: "DFE-Digital/dfe-autocomplete"
gem "govuk-components"
gem "govuk_design_system_formbuilder"
gem "govuk_feature_flags", github: "DFE-Digital/govuk_feature_flags"
gem "govuk_markdown"
gem "mail-notify"

gem "zendesk_api"

# this is used in the example data generation task
gem "factory_bot_rails"
gem "faker"

group :development, :test do
  gem "debug"
  gem "dotenv-rails"
end

group :development do
  gem "rails-erd"
  gem "rladr"
  gem "web-console"

  gem "annotaterb", require: false
  gem "prettier_print", require: false
  gem "rubocop-govuk", require: false
  gem "syntax_tree", require: false
  gem "syntax_tree-haml", require: false
  gem "syntax_tree-rbs", require: false
end

group :test do
  gem "capybara"
  gem "climate_control"
  gem "cuprite"
  gem "pry"
  gem "rspec"
  gem "rspec-rails"
  gem "rspec-retry",
      git: "https://github.com/DFE-Digital/rspec-retry.git",
      branch: "main"
  gem "shoulda-matchers"
  gem "site_prism"
  gem "webmock"
end
