require 'bundler'
Bundler.require

class SpreadsheetSession
    # TODO: change initialise so pass in the spreadsheet_title :) That may change what I've done with spreadsheet_title below
    def initialize()
        # Authenticate a session with your Service Account
        session = GoogleDrive::Session.from_config("client_secret.json")
        # Get the spreadsheet by its title
        spreadsheet = session.spreadsheet_by_title("codebar_spreadsheet_practice")
        # Get the first worksheet
        @worksheet = spreadsheet.worksheets[0]
    end

    def worksheet
        @worksheet
    end

    def spreadsheet_title=(spreadsheet_title)
        @spreadsheet_title = spreadsheet_title
    end

    def title
        @spreadsheet_title
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
