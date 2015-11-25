# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/its'

require 'coveralls'
Coveralls.wear!

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

require 'omniauth_spec_helpers'

RSpec.configure do |config|
  config.include ApplicationHelper
  config.include CoursesHelper
  config.include LoginHelpers
  config.include OmniAuthSpecHelpers
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    OmniAuth.config.test_mode = true

    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :deletion

    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:github]
  end

  config.around(:each) do |example|
    OmniAuth.config.mock_auth[:github] = nil
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
