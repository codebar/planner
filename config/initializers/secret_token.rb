key, token = ENV['PLANNER_SECRET'], ENV['PLANNER_KEY_BASE']
key, token = 'sample-key', 'sample-token' if Rails.env.development? || Rails.env.test?

Planner::Application.config.secret_key_base = key
Planner::Application.config.secret_token = token
