key = Rails.env.test? ? 'test' : ENV['MAILCHIMP_KEY']

Gibbon::Request.api_key = key
Gibbon::Request.timeout = 15
Gibbon::Request.throws_exceptions = false
Gibbon::Request.symbolize_keys = true
