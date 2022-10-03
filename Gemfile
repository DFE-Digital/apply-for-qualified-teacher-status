source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

gem "rails", "~> 7.0.4"

gem "azure-storage-blob"
gem "bootsnap", require: false
gem "business"
gem "cssbundling-rails"
gem "devise"
gem "devise_invitable"
gem "devise-passwordless"
gem "indefinite_article"
gem "jsbundling-rails"
gem "okcomputer"
gem "pagy"
gem "pg"
gem "propshaft"
gem "puma", "~> 5.6"
gem "rack-attack"
gem "ruby-vips"
gem "sentry-rails"
gem "sentry-ruby"
gem "sidekiq"
gem "sitemap_generator"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby] # Windows

gem "dfe-analytics", git: "https://github.com/DFE-Digital/dfe-analytics"
gem "govuk-components"
gem "govuk_design_system_formbuilder"
gem "govuk_markdown"
gem "mail-notify"

# this is used in the example data generation task
gem "factory_bot_rails"
gem "faker"

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
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
  gem "capybara", "~> 3.37"
  gem "climate_control"
  gem "cuprite", "~> 0.13"
  gem "rspec"
  gem "rspec-rails", "~> 6.0.0.rc1"
  gem "shoulda-matchers", "~> 5.2"
  gem "site_prism"
end
