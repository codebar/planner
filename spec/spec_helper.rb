require 'simplecov'
require 'coveralls'
require "codeclimate-test-reporter"
require 'shoulda/matchers'
CodeClimate::TestReporter.start

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
])
SimpleCov.start 'rails' do
  add_group "Presenters", "app/presenters"
  add_group "Policies", "app/policies"
end

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/its'

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

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
