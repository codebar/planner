require 'bundler'
Bundler.require

require_relative 'google_sheet.rb'

class Spreadsheet
  def initialize(google_sheet)
    @google_sheet = google_sheet
  end

  def self.create_for_workshop(workshop, google_service_account_path:)
    title = "Workshop #{workshop.id}: #{workshop.local_date} at #{workshop.host.name}"
    google_sheet = GoogleSheet.create(title, google_service_account_path: google_service_account_path)
    load_spreadsheet_template(google_sheet)
    share_file_permission(google_sheet, workshop)
    new(google_sheet)
  end

  def self.find_by(id, google_service_account_path:)
    google_sheet = GoogleSheet.find(id, google_service_account_path: google_service_account_path)
    new(google_sheet)
  end

  def add_student(student)
    last_row = @google_sheet.num_rows + 1
    @google_sheet[last_row, 1] = student.full_name.to_s
    @google_sheet[last_row, 4] = student.about_you.to_s
    @google_sheet.save
  end

  def id
    @google_sheet.id
  end

  def delete!
    @google_sheet.delete!
  end

  class << self
    private

    def load_spreadsheet_template(google_sheet)
      google_sheet[1, 1] = 'Intro speech:'
      google_sheet[2, 1] = 'Lightning Talk (optional)'
      google_sheet[3, 1] = 'Announcements:'
      google_sheet[4, 2] = '* Wifi'
      google_sheet[5, 2] = '* Desk Space'
      google_sheet[6, 2] = '* Toilets'
      google_sheet[7, 2] = '* Other optional announcements'
      google_sheet[8, 1] = 'Pairing:'
      google_sheet[9, 2] = '* Please identify your coach/student: lock eyes and remember their face'
      google_sheet[10, 2] = '* Please be as quiet as you can while pairing'
      google_sheet[google_sheet.num_rows + 3, 1] = 'Paired Students:'
      google_sheet[google_sheet.num_rows + 11, 1] = '***********'
      google_sheet.save
    end

    def share_file_permission(google_sheet, workshop)
      organisers_emails = workshop.chapter.organisers.map(&:email)
      message = 'Hi, Please find below a link to the pairing spreadsheet ' \
                'for codebar workshop on #{workshop.local_date}.'
      google_sheet.share(organisers_emails, message)
    end
  end
end
