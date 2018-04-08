# Be sure to restart your server when you modify this file.
# Sentry Exception tracking
# 
# NOTE: When the better_errors gem is installed/enabled (e.g in development) excpetions will be caught by
# better_errors and not be seen by raven.


Raven.configure do |config|
	config.dsn = ENV['SENTRY_DSN']
	config.environments = ['production']
	config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end
