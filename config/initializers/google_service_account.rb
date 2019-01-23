require 'tempfile'

if ENV.has_key?('GOOGLE_SERVICE_ACCOUNT')
  begin
    file = Tempfile.create('google_service_account')
    file.write(ENV['GOOGLE_SERVICE_ACCOUNT'])
    Planner::Application.config.google_service_account_path = file.path
    Rails.logger.info("Google service account stored in #{file.path}")
  rescue IOError => e
    Rails.logger.warn(e.inspect)
  ensure
    file.close unless file.nil?
  end
else
  Rails.logger.warn('Google service account is not set. No spreadsheet created.')
end
