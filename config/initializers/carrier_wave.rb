CarrierWave.configure do |config|
  if Rails.env.development?
    config.storage = :file
  elsif Rails.env.production?
    config.cache_dir = "#{Rails.root}/tmp/uploads"
    config.root = Rails.root.join('tmp')
    config.sftp_host = ENV['UPLOADER_ASSET_HOST']
    config.sftp_user = ENV['UPLOADER_USER']
    config.sftp_folder = ENV['UPLOADER_FOLDER']
    config.sftp_url = ENV['UPLOADER_URL']
    config.sftp_options = {
      password: ENV['UPLOADER_PASSW'],
      port: 22
    }
  end
end
