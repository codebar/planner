require 'bundler'
Bundler.require

class CreateSpreadsheet
    def initialize(title)
        @session = GoogleDrive::Session.from_config("client_secret.json")
        @spreadsheet = @session.create_spreadsheet(title)
    end

    def fileid()
        @file_id = @spreadsheet.worksheets_feed_url.split("/")[-3]
    end

    def share_file(organiser_email)
        user_permission = {
          type: 'user',
          role: 'writer',
          email_address: organiser_email
        }
        @spreadsheet.acl.push(user_permission)
    end
end


class UpdateSpreadsheet
    def initialize(spreadsheet_id)
        @session = GoogleDrive::Session.from_config("client_secret.json")
        @spreadsheet = @session.spreadsheet_by_key(spreadsheet_id)
    end

    def add_student(student)
        @worksheet = @spreadsheet.worksheets[0]
        @worksheet.insert_rows(@worksheet.num_rows + 1, [["#{student.full_name}", " ", " ", " " "#{student.about_you}"]])
        @worksheet.save
    end
end
##Note: the above code works, so this is quite functional! :)
#However, outstanding issues to bring this to production.
#All secrets in the client_secret.json belong to my Google account.
# Also, still hardcoding in my email.
# Add message to email sent to organisers
# Add more info to spreadsheet that is created!
