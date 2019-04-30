class GoogleSheet
  def initialize(google_drive_sheet)
    @google_drive_sheet = google_drive_sheet
    @worksheet = google_drive_sheet.worksheets[0]
  end

  def id
    @google_drive_sheet.worksheets_feed_url.split('/')[-3]
  end

  def delete!
    @google_drive_sheet.delete(true)
  end

  def num_rows
    @worksheet.num_rows
  end

  def []=(*args)
    @worksheet[*args[0..-2]] = args[-1]
  end

  def set(row, col, value)
    @worksheet[row, col] = value
  end

  def save
    @worksheet.save
  end

  def share(emails, message)
    emails.each do |organiser_email|
      user_permission = {
        type: 'user',
        role: 'writer',
        email_address: organiser_email
      }
      @google_drive_sheet.acl.push(user_permission, email_message: message)
    end
  end

  class << self
    def create(title, google_service_account_path:)
      session = get_session(google_service_account_path)
      new(session.create_spreadsheet(title))
    end

    def find(id, google_service_account_path:)
      session = get_session(google_service_account_path)
      new(session.spreadsheet_by_key(id))
    end

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
  end
end
