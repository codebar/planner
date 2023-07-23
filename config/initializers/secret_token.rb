key = ENV['PLANNER_SECRET']
key = 'sample-key' if Rails.env.development? || Rails.env.test?

Rails.application.config.secret_key_base = key

