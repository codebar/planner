require 'spreadsheet/spreadsheet'
require 'spreadsheet/google_sheet'
require 'ostruct'

describe Spreadsheet do
  let(:workshop) do
    OpenStruct.new(
      id: 123,
      local_date: Date.new(2019,3,27),
      host: OpenStruct.new(name: 'Shutl'),
      chapter: OpenStruct.new(organisers: [])
    )
  end

  let(:google_sheet) { spy(GoogleSheet) }
  subject(:spreadsheet) { Spreadsheet.new(google_sheet) }

  it 'adds a student' do
    allow(google_sheet).to(receive(:num_rows)).and_return(5)

    spreadsheet.add_student(OpenStruct.new(full_name: "Ada Lovelace", about_you: "Programming"))

    expect(google_sheet).to(have_received(:[]=).with(6, 1, "Ada Lovelace"))
    expect(google_sheet).to(have_received(:[]=).with(6, 4, "Programming"))
    expect(google_sheet).to(have_received(:save))
  end
end
