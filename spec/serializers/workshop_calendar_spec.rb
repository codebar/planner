require 'rails_helper'

RSpec.describe WorkshopCalendar do
  let(:invitation_url) { Faker::Internet.url }

  describe '.new' do
    it 'calls setup during initialization' do
      workshop = Fabricate(:workshop)
      calendar = described_class.new(workshop, invitation_url)

      expect(calendar.calendar.events.count).to eq(1)
    end
  end

  describe '#ical' do
    it 'returns an iCalendar string' do
      workshop = Fabricate(:workshop)
      cal = described_class.new(workshop, invitation_url)

      result = cal.ical

      expect(result).to start_with("BEGIN:VCALENDAR\r\n")
      expect(result).to include("BEGIN:VEVENT\r\n")
      expect(result).to include("END:VEVENT\r\n")
      expect(result).to include("END:VCALENDAR\r\n")
    end

    it 'includes the invitation URL in the event description' do
      workshop = Fabricate(:workshop)
      cal = described_class.new(workshop, invitation_url)

      expect(cal.ical).to include(invitation_url)
    end
  end

  describe 'workshop calendar entry' do
    let(:workshop) { Fabricate(:workshop) }
    let(:calendar) { described_class.new(workshop, invitation_url).calendar }

    it 'has an event associated with it' do
      expect(calendar.events.count).to eq(1)
    end

    context 'with a physical workshop' do
      it 'all required details are set' do
        event = calendar.events.first
        expect(event.organizer.to_s).to eq(workshop.chapter.email)
        expect(event.summary).to eq("codebar @ #{workshop.host.name}")
        expect(event.location.to_s).to eq(AddressPresenter.new(workshop.host.address).to_s)
        expect(event.url.to_s).to eq(invitation_url)
        expect(event.description).to include('Declining or removing this event from your calendar does not update your invitation')
        expect(event.description).to include(invitation_url)
      end
    end

    context 'with a physical workshop that has no host' do
      let(:workshop) { Fabricate(:workshop_no_sponsor, virtual: false) }

      it 'falls back to TBA for host name and address' do
        event = calendar.events.first

        expect(event.summary.to_s).to eq('codebar @ TBA')
        expect(event.location.to_s).to eq('TBA')
        expect(event.organizer.to_s).to eq(workshop.chapter.email)
        expect(event.description).to include(invitation_url)
      end

      it 'serialises the fallback into the iCalendar output' do
        expect(described_class.new(workshop, invitation_url).ical).to include('TBA')
      end
    end

    context 'with a host whose address record has been removed' do
      let(:workshop) do
        Fabricate(:workshop).tap do |w|
          w.host.address.destroy
          w.reload
        end
      end

      it 'keeps the host name and falls back to TBA for the address' do
        event = calendar.events.first

        expect(event.summary.to_s).to eq("codebar @ #{workshop.host.name}")
        expect(event.location.to_s).to eq('TBA')
      end
    end

    context 'with a virtual workshop' do
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
