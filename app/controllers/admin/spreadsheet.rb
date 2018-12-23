require 'bundler'
Bundler.require

class CreateSpreadsheet
    def initialize(title)
      begin
        begin
          orig_stdin, $stdin = $stdin, StringIO.new
          session = GoogleDrive::Session.from_config("client_secret.json")
        ensure
          $stdin = orig_stdin
        end
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
      rescue => e
        puts e.inspect
      end
    end

    def fileid()
        begin
          @file_id = @spreadsheet.worksheets_feed_url.split("/")[-3]
        rescue => e
          puts e.inspect
        end
    end

    def share_file_permission(organiser_email, date)
        user_permission = {
          type: 'user',
          role: 'writer',
          email_address: organiser_email
        }
        message = "Hi, Please find below a link to the pairing spreadsheet for codebar workshop on #{date}."
        begin
          @spreadsheet.acl.push(user_permission, {email_message: message})
        rescue => e
          puts e.inspect
        end
    end

    def share(organisers_emails, date)
      organisers_emails.each { |organiser_email| share_file_permission(organiser_email, date) }
    end
end


class UpdateSpreadsheet
    def initialize(spreadsheet_id)
      begin
        begin
          orig_stdin, $stdin = $stdin, StringIO.new
          session = GoogleDrive::Session.from_config("client_secret.json")
        ensure
          $stdin = orig_stdin
        end
        @spreadsheet = session.spreadsheet_by_key(spreadsheet_id)
      rescue => e
        puts e.inspect
      end
    end

    def add_student(student)
      begin
        worksheet = @spreadsheet.worksheets[0]
        worksheet[worksheet.num_rows + 1, 1] = "#{student.full_name}"
        worksheet[worksheet.num_rows, 4] = "#{student.about_you}"
        worksheet.save
      rescue => e
        puts e.inspect
      end
    end
end
