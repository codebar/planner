require 'spec_helper'

RSpec.describe Workshop, type: :model  do
  subject(:workshop) { Fabricate(:workshop) }
  include_examples "Invitable", :workshop_invitation, :workshop

  context 'time zone fields' do
    let(:workshop) { Fabricate.build(:workshop, chapter: Fabricate(:chapter, time_zone: 'Pacific Time (US & Canada)')) }
    let(:pacific_time) { ActiveSupport::TimeZone['Pacific Time (US & Canada)'].local(2015, 6, 12, 18, 30) }
    let(:utc_time) { pacific_time.in_time_zone('UTC') }

    context 'date_and_time' do
      it 'saves the local time in UTC' do
        workshop.update!(
          local_date: '12/06/2015',
          local_time: '18:30'
        )

        expect(workshop.read_attribute(:date_and_time)).to eq(utc_time)
      end

      it 'retrieves the local time from the saved UTC value' do
        workshop.update_attribute(:date_and_time, utc_time)

        expect(workshop.date_and_time).to eq(pacific_time)
        expect(workshop.date_and_time.zone).to eq('PDT')
      end
    end

    context 'rsvp_opens_at' do
      it 'saves the local time in UTC' do
        workshop.update!(
          rsvp_open_local_date: '12/06/2015',
          rsvp_open_local_time: '18:30'
        )

        expect(workshop.read_attribute(:rsvp_opens_at)).to eq(utc_time)
      end

      it 'retrieves the local time from the saved UTC value' do
        workshop.update_attribute(:rsvp_opens_at, utc_time)

        expect(workshop.rsvp_opens_at).to eq(pacific_time)
        expect(workshop.rsvp_opens_at.zone).to eq('PDT')
      end
    end
  end

  context '#rsvp_available?' do
    context 'rsvp is available' do
      it 'when the event is in the future' do
        workshop.date_and_time = 1.day.from_now

        expect(workshop.rsvp_available?).to be(true)
      end

      it 'when rsvp_closes_at is in the future' do
        workshop.rsvp_closes_at = 2.hours.from_now

        expect(workshop.rsvp_available?).to be(true)
      end

      it 'when rsvp_closes_at is in another timezone' do
        workshop.rsvp_closes_at = 2.hours.from_now.in_time_zone('Pacific Time (US & Canada)')

        expect(workshop.rsvp_available?).to be(true)
      end
    end

    context 'rsvp is not available' do
      it 'when rsvp_closes_at is in the past' do
        workshop.rsvp_closes_at = 2.hours.ago

        expect(workshop.rsvp_available?).to be(false)
      end
    end
  end

  context '#to_s' do
    it 'when physical workshop' do
      expect(workshop.to_s).to eq('Workshop')
    end

    it 'when virtual workshop' do
      workshop = Workshop.new(virtual: true)
      expect(workshop.to_s).to eq('Virtual Workshop')
    end
  end

  context '#scopes' do
    describe '#host' do
      let(:sponsor) { Fabricate(:sponsor) }

      before do
        workshop.workshop_sponsors.delete_all
        Fabricate(:workshop_sponsor, sponsor: sponsor, workshop: workshop, host: true)
      end

      it { expect(workshop.host).to eq(sponsor) }
    end

    context 'attendances' do
      it '#attendee? for students' do
        attendee_invites = 4.times.collect { Fabricate(:workshop_invitation, workshop: workshop, attending: true) }
        nonattendee_invites = 2.times.collect { Fabricate(:workshop_invitation, workshop: workshop, attending: false) }

        attendee_invites.each { |a| expect(workshop.attendee?(a.member)).to be true }
        nonattendee_invites.each { |a| expect(workshop.attendee?(a.member)).to be false }
      end

      it '#attendee? for coaches' do
        attendee_invites = 4.times.collect { Fabricate(:coach_workshop_invitation, workshop: workshop, attending: true) }
        nonattendee_invites = 2.times.collect { Fabricate(:coach_workshop_invitation, workshop: workshop, attending: false) }

        attendee_invites.each { |a| expect(workshop.attendee?(a.member)).to be true }
        nonattendee_invites.each { |a| expect(workshop.attendee?(a.member)).to be false }
      end
    end

    context 'Waitlist attendance' do
      it '#waitlisted? for students' do
        invitations = 5.times.collect { Fabricate(:workshop_invitation, workshop: workshop) }
        invitations.each { |invitation| WaitingList.add(invitation) }
        attendee_invites = 4.times.collect { Fabricate(:workshop_invitation, workshop: workshop, attending: true) }

        invitations.each { |a| expect(workshop.waitlisted?(a.member)).to be true }
        attendee_invites.each { |a| expect(workshop.waitlisted?(a.member)).to be false }
      end

      it '#waitlisted? for coaches' do
        invitations = 5.times.collect { Fabricate(:coach_workshop_invitation, workshop: workshop) }
        invitations.each { |invitation| WaitingList.add(invitation) }
        attendee_invites = 4.times.collect { Fabricate(:coach_workshop_invitation, workshop: workshop, attending: true) }

        invitations.each { |a| expect(workshop.waitlisted?(a.member)).to be true }
        attendee_invites.each { |a| expect(workshop.waitlisted?(a.member)).to be false }
      end
    end
  end

  context '#invitable_yet?' do
    it 'is invitable if invitable set to true, no RSVP open time/date set' do
      workshop = Fabricate.build(:workshop, invitable: true)
      expect(workshop.invitable_yet?).to be true
    end

    it 'is invitable if RSVP open date/time in past, and invitable set to false' do
      workshop = Fabricate.build(:workshop, invitable: false, rsvp_opens_at: Time.zone.now - 1.day)
      expect(workshop.invitable_yet?).to be true
    end

    it 'is invitable if RSVP open date/time in future, and invitable set to true' do
      workshop = Fabricate.build(:workshop, invitable: true, rsvp_opens_at: Time.zone.now - 1.day)
      expect(workshop.invitable_yet?).to be true
    end

    it 'is NOT invitable if RSVP open date/time in future, and invitable set to false' do
      workshop = Fabricate.build(:workshop, invitable: false, rsvp_opens_at: Time.zone.now + 1.day)
      expect(workshop.invitable_yet?).to be false
    end
  end
end
