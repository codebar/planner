require 'bundler'
Bundler.require

class CreateSpreadsheet
    def initialize(title)
        session = GoogleDrive::Session.from_config("client_secret.json")
        @spreadsheet = session.create_spreadsheet(title)
        worksheet = @spreadsheet.worksheets[0]
        worksheet[1, 1] = "Intro speech:"
        worksheet[2, 1] = "Lightning Talk (optional)"
        worksheet[3, 1] = "Announcements:"
        worksheet[4, 2] = "* Wifi"
        worksheet[5, 2] = "* Desk Space"
        worksheet[6, 2] = "* Toilets"
        worksheet[7, 2] = "* Other optional announcements"
        worksheet[8, 1] = "Pairing:"
        worksheet[9, 2] = "* Please identify your coach/student: lock eyes and remember their face"
        worksheet[10, 2] = "* Please be as quiet as you can while pairing"

        worksheet.insert_rows(worksheet.num_rows + 3, [["Paired Students:"]])
        worksheet.insert_rows(worksheet.num_rows + 11, [["***********"]])

        worksheet.save
    end

    def fileid()
        @file_id = @spreadsheet.worksheets_feed_url.split("/")[-3]
    end

    def share_file_permission(organiser_email, date)
        user_permission = {
          type: 'user',
          role: 'writer',
          email_address: organiser_email
        }
        message = "Hi, Please find below a link to the pairing spreadsheet for codebar workshop on #{date}."
        @spreadsheet.acl.push(user_permission, {email_message: message})
    end

    def share(organiser_emails, date)
      organiser_emails.each { |organiser_email| share_file_permission(organiser_email, date) }
    end
end


class UpdateSpreadsheet
    def initialize(spreadsheet_id)
        session = GoogleDrive::Session.from_config("client_secret.json")
        @spreadsheet = session.spreadsheet_by_key(spreadsheet_id)
    end

    def add_student(student)
        worksheet = @spreadsheet.worksheets[0]
        worksheet[worksheet.num_rows + 1, 1] = "#{student.full_name}"
        worksheet[worksheet.num_rows, 4] = "#{student.about_you}"
        worksheet.save
    end
end

# Note: the above code works, so this is quite functional! :)
#However, outstanding issues to bring this to production.
#All secrets in the client_secret.json belong to my Google account.
# Also, still hardcoding in my email(s) (but should be able to just remove this for production)
# How should I test this?
# I need these wrapped in try/catch!
