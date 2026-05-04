# frozen_string_literal: true

# Capybara driver for Lightpanda browser using capybara-lightpanda gem
# https://github.com/navidemad/capybara-lightpanda
#
# Usage:
#   Run tests with LIGHTPANDA=true: LIGHTPANDA=true bundle exec rspec spec/features/some_test.rb

if ENV['LIGHTPANDA'] == 'true'
  require 'capybara-lightpanda'

  Capybara.javascript_driver = :lightpanda
  puts "Using Lightpanda browser (capybara-lightpanda) for JavaScript tests"
end
