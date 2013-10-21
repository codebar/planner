key = Rails.env.eql?("production") ? ENV['PLANNER_SECRET'] : "sample-key"

raise "No secret!" if key.nil?

Planner::Application.config.secret_key_base = key
