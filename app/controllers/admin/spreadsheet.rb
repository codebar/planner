require 'bundler'
Bundler.require

class SpreadsheetSession
    def initialize(title)
        @title = title
        # Authenticate a session with your Service Account
        session = GoogleDrive::Session.from_config("client_secret.json")
        # Get the spreadsheet by its title
        @spreadsheet = session.create_spreadsheet(@title)
        #@file_id = @spreadsheet.worksheets_feed_url.split("/")[-3]
        # Get the first worksheet
        #@worksheet = @spreadsheet.worksheets[0]
        #worksheet.insert_rows(worksheet.num_rows + 1, [["New", "Worksheet"]])
        #@worksheet.save

        #file_id = ws.worksheet_feed_url.split("/")[-4]

        #drive = settings.google_client_driver

        #  new_permission = drive.permissions.insert.request_schema.new({
        #      'value' => "codebar-planner@codebar-planner.iam.gserviceaccount.com",
        #      'type' => "user",
        #      'role' => "editor"
        #  })

         # result = client.execute(
        #    :api_method => drive.permissions.insert,
        #    :body_object => new_permission,
        #    :parameters => { 'fileId' => file_id })
    end

    def fileid()
        @file_id = @spreadsheet.worksheets_feed_url.split("/")[-3]
    end

    def add_student(student)

        @worksheet.insert_rows(worksheet.num_rows + 1, [["#{student.full_name}", " ", " ", " " "#{student.about_you}"]])

        worksheet.save
    end

end

##Note: the above code works, so this is quite functional! :)
#However, many outstanding issues to bring this to production:
#only works with the hardcoded: "codebar_spreadsheet_practice"
#So, haven't set up how to programmatically create new spreadsheet for each new workshop?
#all secrets in the client_secret.json belong to my Google account.
