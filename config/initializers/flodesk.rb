require 'services/flodesk'

key = Rails.env.test? ? 'test' : ENV['FLODESK_KEY']

logger.warn 'Missing key for Flodesk' unless key

Flodesk::Client.api_key = key
Flodesk::Client.complete_timeout = 15
Flodesk::Client.open_timeout = 15
