require 'google/apis/drive_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
APPLICATION_NAME = 'Drive API Ruby Quickstart'.freeze
CREDENTIALS_PATH = 'credentials.json'.freeze
# The file token.yaml stores the user's access and refresh tokens, and is
# created automatically when the authorization flow completes for the first
# time.
TOKEN_PATH = 'token.yaml'.freeze
SCOPE = Google::Apis::DriveV3::AUTH_DRIVE

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  @client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
  puts "\n************************** #{@client_id} ****************\n "
  token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(@client_id, SCOPE, token_store)
  user_id = 'default'
  puts "\n************************** #{user_id} ****************\n "
  credentials = authorizer.get_credentials(user_id)
  puts "\n************************** #{credentials} ****************\n "
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts 'Open the following URL in the browser and enter the ' \
         "resulting code after authorization:\n" + url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI
    )
  end
  credentials
end

# Initialize the API
drive_service = Google::Apis::DriveV3::DriveService.new
drive_service.client_options.application_name = APPLICATION_NAME
drive_service.authorization = authorize

# file_id = '1ftczLDHv7eZd3em9vUPgHB9rNvkf5APgaK3PYlwOsZ0'
# callback = lambda do |res, err|
#   if err
#     # Handle error...
#     puts err.body
#   else
#     puts "Permission ID: #{res.id}"
#   end
# end
# drive_service.batch do |service|
#   user_permission = {
#       type: 'user',
#       role: 'writer',
#       email_address: 'karadelamarck@gmail.com'
#   }
#   service.create_permission(file_id,
#                             user_permission,
#                             fields: 'id',
#                             &callback)
#   domain_permission = {
#       type: 'domain',
#       role: 'reader',
#       domain: 'example.com'
#   }
#   service.create_permission(file_id,
#                             domain_permission,
#                             fields: 'id',
#                             &callback)
# end


#List the 10 most recently modified files.
response = drive_service.list_files(page_size: 10,
                              fields: 'nextPageToken, files(id, name)')
puts 'Files:'
puts 'No files found' if response.files.empty?
response.files.each do |file|
  puts "#{file.name} (#{file.id})"
end








# file_id = '1mccalPeuaCLUsQF8lFsLnntMJ3Fk2t8pxjCIzLasfDc'
# callback = lambda do |res, err|
#   if err
#     # Handle error...
#     puts err.body
#   else
#     puts "Permission ID: #{res.id}"
#   end
# end
#
# user_permission = Google::Apis::DriveV3::Permission.new(
#     type: 'user',
#     role: 'writer',
#     email_address: 'karadelamarck@gmail.com'
# )
# service.create_permission(file_id,
#                           user_permission,
#                           fields: 'id',
#                           &callback)




# real_file_id = '1sTWaJ_j7PkjzaBWtNc3IzovK5hQf21FbOw9yLeeLPNQ'
# def share_file(real_file_id, real_user, real_domain)
#     ids = []
#     # [START drive_share_file]
#     file_id = '1sTWaJ_j7PkjzaBWtNc3IzovK5hQf21FbOw9yLeeLPNQ'
#     # [START_EXCLUDE silent]
#     file_id = real_file_id
#     # [END_EXCLUDE]
#     callback = lambda do |res, err|
#       if err
#         # Handle error...
#         puts err.body
#       else
#         puts "Permission ID: #{res.id}"
#         # [START_EXCLUDE silent]
#         ids << res.id
#         # [END_EXCLUDE]
#       end
#     end
#     drive_service.batch do |service|
#       user_permission = {
#           type: 'user',
#           role: 'writer',
#           email_address: 'user@example.com'
#       }
#       # [START_EXCLUDE silent]
#       user_permission[:email_address] = 'karadelamarck@gmail.com'
#       # [END_EXCLUDE]
#       service.create_permission(file_id,
#                                 user_permission,
#                                 fields: 'id',
#                                 &callback)
#       domain_permission = {
#           type: 'domain',
#           role: 'reader',
#           domain: 'example.com'
#       }
#       # [START_EXCLUDE silent]
#       domain_permission[:domain] = real_domain
#       # [END_EXCLUDE]
#       service.create_permission(file_id,
#                                 domain_permission,
#                                 fields: 'id',
#                                 &callback)
#     end
#     # [END drive_share_file]
#     return ids
#   end
