require 'bundler'
Bundler.require

class Spreadsheet
  def initialize(google_sheet)
    @google_sheet = google_sheet
  end

  def self.create_for_workshop(workshop, google_service_account_path:)
    session = get_session(google_service_account_path)
    title = "Workshop #{workshop.id}: #{workshop.local_date} at #{workshop.host.name}"
    google_sheet = session.create_spreadsheet(title)
    load_spreadsheet_template(google_sheet)
    share_file_permission(google_sheet, workshop)
    new(google_sheet)
  end

  def self.find_by(id, google_service_account_path:)
    session = get_session(google_service_account_path)
    google_sheet = session.spreadsheet_by_key(id)
    new(google_sheet)
  end

  def add_student(student)
    worksheet = @google_sheet.worksheets[0]
    last_row = worksheet.num_rows + 1
    worksheet[last_row, 1] = student.full_name.to_s
    worksheet[last_row, 4] = student.about_you.to_s
    worksheet.save
  end

  def id
    @google_sheet.worksheets_feed_url.split('/')[-3]
  end

  def delete!
    @google_sheet.delete(true)
  end

  class << self
    private

    def get_session(config)
      begin
        orig_stdin, $stdin = $stdin, StringIO.new
        session = GoogleDrive::Session.from_config(config)
      ensure
        $stdin = orig_stdin
      end
      session
    end

    def load_spreadsheet_template(google_sheet)
      worksheet = google_sheet.worksheets[0]
      worksheet[1, 1] = 'Intro speech:'
      worksheet[2, 1] = 'Lightning Talk (optional)'
      worksheet[3, 1] = 'Announcements:'
      worksheet[4, 2] = '* Wifi'
      worksheet[5, 2] = '* Desk Space'
      worksheet[6, 2] = '* Toilets'
      worksheet[7, 2] = '* Other optional announcements'
      worksheet[8, 1] = 'Pairing:'
      worksheet[9, 2] = '* Please identify your coach/student: lock eyes and remember their face'
      worksheet[10, 2] = '* Please be as quiet as you can while pairing'
      worksheet.insert_rows(worksheet.num_rows + 3, [['Paired Students:']])
      worksheet.insert_rows(worksheet.num_rows + 11, [['***********']])
      worksheet.save
    end

    def share_file_permission(google_sheet, workshop)
      organisers_emails = workshop.chapter.organisers.map(&:email)
      organisers_emails.each do |organiser_email|
        user_permission = {
          type: 'user',
          role: 'writer',
          email_address: organiser_email
        }
        message = 'Hi, Please find below a link to the pairing spreadsheet ' \
                  'for codebar workshop on #{workshop.local_date}.'
        google_sheet.acl.push(user_permission, email_message: message)
      end
    end
  end
end
