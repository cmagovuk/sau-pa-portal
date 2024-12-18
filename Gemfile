source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version").chomp

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 7.0.8", ">= 7.0.8.1"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"

# Use postgresql as the database for Active Record
gem "pg", "= 1.5.6"

# Use Puma as the app server
gem "puma", "~> 5.3"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

# Manage multiple processes i.e. web server and webpack
gem "foreman"

# Canonical meta tag
gem "canonical-rails"

# DfE gems for generating GOV.UK Design System markup
gem "govuk-components"
gem "govuk_design_system_formbuilder"

# Ruby client for GOV.UK Notifications API
gem "notifications-ruby-client"

# Azure storage
gem "azure-storage-blob", require: false

# HTTP client
gem "faraday", "~> 1.10"

# JWT token handling
gem "jwt"

# PDF generation
gem "prawn-rails"

# Excel generation
gem "caxlsx"
gem "caxlsx_rails"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]

  # GOV.UK interpretation of rubocop for linting Ruby
  gem "rubocop-govuk"
  gem "scss_lint-govuk"

  # Debugging
  gem "pry-byebug"

  # Testing framework
  gem "rspec-rails", "~> 5.0.1"
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", "~> 3.35"

  gem "dotenv-rails"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "listen", ">= 3.0.5", "< 3.7"
  gem "web-console", ">= 3.3.0"

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :test do
  gem "rails-controller-testing"
  gem "shoulda-matchers"
  gem "webdrivers", "~> 4.6"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
