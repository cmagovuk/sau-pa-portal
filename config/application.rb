require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GovukSauPortal
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.assets.paths << Rails.root.join('node_modules/govuk-frontend/dist/govuk/assets')

    config.time_zone = "Europe/London"
    config.action_dispatch.cookies_same_site_protection = :strict
    config.active_storage.content_types_allowed_inline -= ["application/pdf"]
    config.active_storage.content_types_to_server_as_binary = ["application/pdf"]

    config.exceptions_app = routes

    #config.middleware.use Rack::Deflater

    # Load Govuk template set from "config/govuk_notify_templates.yml"
    config.govuk_notify_templates = config_for(
      :govuk_notify_templates, env: ENV.fetch("GOVUK_NOTIFY_ENV", "test")
    ).with_indifferent_access

    config.x.cookie_expiry = 1.year

    config.x.analytics_tracking_id = ENV['GA_TRACKING_ID']
    config.x.maintenance_text = ENV["MAINTENANCE_TEXT"]
    config.x.transparency_link = ENV.fetch("TRANSPARENCY_LINK","")

    config.role_mappings = ENV.fetch("ROLE_MAPPINGS","").split(%r{,\s*}).to_h{ |i| i.split(":")}
    config.pap_url = ENV.fetch("PAP_URL","")
    config.sau_email_format = ENV.fetch("SAU_EMAIL_FORMAT","")
    config.feedback_link = ENV.fetch("FEEDBACK_LINK","")
    config.x.feedback_email = ENV.fetch("FEEDBACK_EMAIL","")
  end
end
