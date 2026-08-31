RSpec.describe MeetingPresenter do
  let(:meeting) { Fabricate(:meeting) }
  let(:event) { described_class.new(meeting) }

  it '#sponsors' do
    expect(event.sponsors).to eq([])
  end

  it '#description' do
    expect(event.description).to eq(meeting.description)
  end

  it '#venue' do
    expect(event.venue).to eq(meeting.venue)
  end

  it '#attendees_emails' do
    attendees = Fabricate.times(4, :attending_meeting_invitation, meeting:)
    emails = attendees.map(&:member).map(&:email)
    emails.each do |email|
      expect(event.attendees_emails).to include(email)
    end
  end

  it '#time' do
    allow(meeting).to receive(:date_and_time).and_return(Time.zone.now)

    event.time

    expect(meeting).to have_received(:date_and_time)
  end

  it '#to_s' do
    expect(event.to_s).to eq(meeting.name)
  end

  it '#admin_path' do
    expect(event.admin_path).to eq(Rails.application.routes.url_helpers.admin_meeting_path(meeting))
  end
end
