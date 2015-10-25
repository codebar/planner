CarrierWave.configure do |config|
  if Rails.env.production?
    config.root = "#{Rails.root}/tmp"
    config.cache_dir = "#{Rails.root}/tmp/uploads"
    config.storage = :sftp
    config.sftp_host = ENV['UPLOADER_ASSET_HOST']
    config.sftp_user = ENV['UPLOADER_USER']
    config.sftp_folder = ENV['UPLOADER_FOLDER']
    config.sftp_url = ENV['UPLOADER_URL']
    config.sftp_options = {
      :password => ENV['UPLOADER_PASSW'],
      :port     => 22
    }
  elsif Rails.env.test?
    config.storage = :file
    config.enable_processing = false
    config.root = "#{Rails.root}/tmp/carrierwave"
  elsif Rails.env.development?
    config.storage = :file    
  end
end
