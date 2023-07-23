require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Planner
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'London'
    config.active_record.default_timezone = :local

    # Remove config.active_record.raise_in_transactional_callbacks, which is deprecated and removed without replacement, see 
    # https://apidock.com/rails/v5.0.0.1/ActiveRecord/Transactions/ClassMethods/raise_in_transactional_callbacks%3D.
    # config.active_record.raise_in_transactional_callbacks = true
    
    # Related to https://stackoverflow.com/questions/72970170/upgrading-to-rails-6-1-6-1-causes-psychdisallowedclass-tried-to-load-unspecif
    # and https://discuss.rubyonrails.org/t/cve-2022-32224-possible-rce-escalation-bug-with-serialized-columns-in-active-record/81017
    config.active_record.yaml_column_permitted_classes = [Symbol, Date, Time, ActiveSupport::TimeWithZone, ActiveSupport::TimeZone, ActiveSupport::HashWithIndifferentAccess]
    # Allow Skylight to show insights from local development.
    # More info at https://skylight.io/support/environments
    config.skylight.environments << 'development'
  end
end

require 'csv' # the standard library CSV Class
