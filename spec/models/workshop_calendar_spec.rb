require 'spec_helper'
describe WorkshopCalendar do
  let(:invitation_url) { Faker::Internet.url }
  let(:calendar) { WorkshopCalendar.new(workshop, invitation_url).calendar }

  describe 'workshop calendar entry' do
    let(:workshop) { Fabricate(:workshop) }
    it 'has an event associated with it' do
      expect(calendar.events.count).to eq(1)
    end

    context 'physical workshop' do
      it 'all required details are set' do
        event = calendar.events.first
        expect(event.organizer.to_s).to eq(workshop.chapter.email)
        expect(event.summary).to eq("codebar @ #{workshop.host.name}")
        expect(event.location.to_s).to eq(AddressPresenter.new(workshop.host.address).to_s)
        expect(event.url.to_s).to eq(invitation_url)
        expect(event.description).to include("Declining or removing this event from your calendar does not update your invitation")
        expect(event.description).to include(invitation_url)
      end
    end

    context 'virtual workshop' do
      let(:workshop) { Fabricate(:virtual_workshop) }

      it 'all required details are set' do
        event = calendar.events.first
        expect(event.organizer.to_s).to eq(workshop.chapter.email)
        expect(event.summary).to eq('codebar @ Slack')
        expect(event.location.to_s).to eq('codebar Slack (https://slack.codebar.io)')
        expect(event.description).to include("##{workshop.slack_channel} (#{workshop.slack_channel_link}")
        expect(event.description).to include(invitation_url)
        expect(event.url.to_s).to eq(invitation_url)
      end
    end
  end
end
