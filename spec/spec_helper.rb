require 'simplecov'
require 'simplecov-lcov'
require 'shoulda/matchers'

# Fix incompatibility of simplecov-lcov with older versions of simplecov that are not expresses in its gemspec.
# https://github.com/fortissimo1997/simplecov-lcov/pull/25

if !SimpleCov.respond_to?(:branch_coverage)
  module SimpleCov
    def self.branch_coverage?
      false
    end
  end
end

SimpleCov::Formatter::LcovFormatter.config do |c|
  c.report_with_single_file = true
  c.single_report_path = 'coverage/lcov.info'
end

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter,
  ]
)

SimpleCov.start do
  add_filter 'spec/'
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  config.include ApplicationHelper
  config.include LoginHelpers
  config.include ActiveSupport::Testing::TimeHelpers
  config.include SelectFromChosen, type: :feature
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.order = 'random'
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # See https://github.com/DatabaseCleaner/database_cleaner#rspec-with-capybara-example
  config.before(:suite) do
    if config.use_transactional_fixtures?
      raise(<<-MSG)
        Delete line `config.use_transactional_fixtures = true` from spec_helper.rb
        (or set it to false) to prevent uncommitted transactions being used in
        JavaScript-dependent specs.

        During testing, the app-under-test that the browser driver connects to
        uses a different database connection to the database connection used by
        the spec. The app's database connection would not be able to access
        uncommitted transaction data setup over the spec's database connection.
      MSG
    end

    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :deletion
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  # Driver is using an external browser with an app
  # under test that does *not* share a database connection with the
  # specs, so use truncation strategy. This config is order dependent
  # and must be BELOW the main `config.before(:each)` configuration
  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  # This block must be here, do not combine with the other `config.before(:each)` block.
  # This makes it so Capybara can see the database.
  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after do |example|
    # Take a screenshot if the example failed and JavaScript is enabled
    if example.exception && defined?(page) && Capybara.current_driver == :chrome
      # Get the filename and line number of the failing spec
      location = example.metadata[:location]
      filename, line_number = location.split(':')

      # Build a custom filename for the screenshot
      screenshot_filename = "#{filename}:#{line_number}.png"

      # Save the screenshot using the custom filename
      page.save_screenshot(screenshot_filename, full: true)
    end
  end

  config.example_status_persistence_file_path = 'tmp/spec_failures'

  if Bullet.enable?
    config.around(:each) do |example|
      Bullet.start_request
      example.run
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

CarrierWave.configure do |config|
  config.enable_processing = false
  config.storage = :file
  # NOTE: We're taking this out for now because it results in:
  #  ActionController::RoutingError:
  #  No route matches [GET] "/uploads/sponsor/avatar/1/thumb_the-guardian.png"
  # ...
  # Your application server raised an error - It has been raised in your test code because Capybara.raise_server_errors == true
  #
  # Ideally there would be a clear seperation between production uploads and testing uploads. Testing uploads would also be cleaned up
  # see https://til.codes/testing-carrierwave-file-uploads-with-rspec-and-factorygirl/.
  # Funny enough this issue has been present for a while. For some reason Capybara wasnraising server errors!
  # config.root = Rails.root.join('tmp')
end
