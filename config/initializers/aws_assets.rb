# Shared S3 asset settings for CarrierWave storage and maintenance tasks.
# This file loads before carrier_wave.rb (initializers run alphabetically) so
# both read one source of truth.
AWS_ASSETS = {
  bucket: ENV.fetch('S3_BUCKET_NAME', 'prod-sponsor-logos'),
  region: ENV.fetch('AWS_REGION', 'eu-north-1')
}.freeze
