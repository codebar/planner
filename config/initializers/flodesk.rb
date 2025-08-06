require 'flodesk'

key = Rails.env.test? ? 'test' : ENV['FLODESK_KEY']
Rails.logger.warn 'Missing FLODESK_KEY environment variable' unless key

# We use Flodesk for newsletter sending, so we need both values
Rails.logger.warn 'Missing NEWSLETTER_ID environment variable' unless ENV['NEWSLETTER_ID']

Flodesk::Client.api_key = key
Flodesk::Client.complete_timeout = 15
Flodesk::Client.open_timeout = 15
