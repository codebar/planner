require 'spreadsheet/spreadsheet'
require 'ostruct'
require 'dotenv'
require 'google_drive'

describe Spreadsheet do
  before(:each) do
    Dotenv.load
  end

  after(:each) do
    spreadsheet.delete!
  end

  let(:workshop) do
    OpenStruct.new(
      id: 123,
      local_date: Date.new(2019,3,27),
      host: OpenStruct.new(name: 'Shutl'),
      chapter: OpenStruct.new(organisers: [])
    )
  end
  let(:google_service_account_path) { get_service_account() }

  subject(:spreadsheet) do
    Spreadsheet.create_for_workshop(
      workshop,
      google_service_account_path: google_service_account_path
    )
  end

  xit 'creates spreadsheet and adds student' do
    session = get_session(google_service_account_path)
    google_sheet = session.spreadsheet_by_key(spreadsheet.id)
    worksheet = google_sheet.worksheets[0]

    expect(google_sheet.title).to(eq("Workshop 123: 2019-03-27 at Shutl"))

    spreadsheet.add_student(OpenStruct.new(full_name: "Ada Lovelace", about_you: "Programming"))

    expect(worksheet[worksheet.num_rows, 1]).to(eq("Ada Lovelace"))
    expect(worksheet[worksheet.num_rows, 4]).to(eq("Programming"))

    found_spreadsheet = Spreadsheet.find_by(
      spreadsheet.id,
      google_service_account_path: google_service_account_path
    )

    expect(found_spreadsheet.id).to(eq(spreadsheet.id))
  end
end

def get_service_account()
  google_service_account_file = Tempfile.create('google_service_account')
  google_service_account_file.write(ENV['GOOGLE_SERVICE_ACCOUNT'])
  google_service_account_file.close
  google_service_account_file.path
end

def get_session(config)
  begin
    orig_stdin, $stdin = $stdin, StringIO.new
    session = GoogleDrive::Session.from_config(config)
  ensure
    $stdin = orig_stdin
  end
  session
end
