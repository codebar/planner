CarrierWave.configure do |config|
  config.cache_storage = :file

  if Rails.env.development?
    config.storage = :file
  elsif Rails.env.production?
    config.storage    = :aws
    config.aws_bucket = ENV.fetch('S3_BUCKET_NAME', 'prod-sponsor-logos')
    config.aws_acl    = 'public-read'  
    config.aws_authenticated_url_expiration = 60 * 60 * 24 * 7  
    config.aws_credentials = {
      access_key_id:     ENV.fetch('AWS_ACCESS_KEY'),
      secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
      region:            ENV.fetch('AWS_REGION', 'eu-north-1') # Required
    }
  end
end
