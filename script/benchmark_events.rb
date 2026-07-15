#!/usr/bin/env ruby
# Run: DB_NAME=codebar_dump bundle exec ruby script/benchmark_events.rb
ENV["RAILS_ENV"] ||= "development"
require_relative "../config/environment"
require "benchmark"

session = ActionDispatch::Integration::Session.new(Rails.application)
session.host = "localhost"

def measure(session, path)
  qc = 0
  cb = ->(*, **) { qc += 1 }
  time = nil
  ActiveSupport::Notifications.subscribed(cb, "sql.active_record") do
    time = Benchmark.measure { session.get(path) }
  end
  [time.real, qc]
end

puts "=== Database: #{ActiveRecord::Base.connection_db_config.database} ===\n\n"

%w[/events/upcoming /events/past /events/past?page=2].each do |path|
  ActiveRecord::Base.connection.query_cache.clear
  Rails.cache.clear if Rails.cache

  cold_t, cold_q = measure(session, path)
  warm = 3.times.map { measure(session, path).first }

  puts "#{path}"
  puts "  cold: #{cold_t.round(3)}s | #{cold_q} queries"
  puts "  warm: #{warm.sort[1].round(3)}s (min #{warm.min.round(3)}, max #{warm.max.round(3)})"
  puts
end
