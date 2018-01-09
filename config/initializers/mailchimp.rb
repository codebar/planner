key = Rails.env.test? ? 'test' : ENV['MAILCHIMP_KEY']

Gibbon::API.api_key = key
Gibbon::API.timeout = 15
Gibbon::API.throws_exceptions = false
