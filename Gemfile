source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

gem "rails", "7.0.5.1"

gem "activerecord-session_store"
gem "azure-storage-blob"
gem "bootsnap", require: false
gem "business"
gem "cssbundling-rails"
gem "devise"
gem "devise_invitable"
gem "devise-passwordless"
gem "email_address"
gem "faraday"
gem "indefinite_article"
gem "jsbundling-rails"
gem "okcomputer"
gem "pagy"
gem "pg"
gem "propshaft"
gem "puma"
gem "pundit"
gem "rack-attack"
gem "rotp"
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

# this is used in the example data generation task
gem "factory_bot_rails"
gem "faker"

group :development, :test do
  gem "debug"
  gem "dotenv-rails"
end

group :development do
  gem "rladr"
  gem "web-console"

  gem "annotate", require: false
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
  gem "rspec"
  gem "rspec-rails"
  gem "shoulda-matchers"
  gem "site_prism"
  gem "webmock"
end
