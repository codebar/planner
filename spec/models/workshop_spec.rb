require 'spec_helper'

describe Workshop do
  subject(:workshop) { Fabricate(:workshop) }

  it { should respond_to(:title) }
  it { should respond_to(:description) }
  it { should respond_to(:date_and_time) }
  it { should respond_to(:sponsors) }
  it { should respond_to(:workshop_sponsors) }
  it { should respond_to(:rsvp_open_date) }
  it { should respond_to(:rsvp_open_time) }

  context '#before_save' do
    let(:workshop) { Fabricate.build(:workshop, chapter: Fabricate(:chapter)) }

    it 'merges date_and_time and time' do
      workshop.date_and_time = Time.zone.local(2015, 11, 12, 12, 0)
      workshop.time = Time.utc(2000, 01, 01, 18, 30)

      workshop.save

      expect(workshop.date_and_time).to eq(Time.zone.local(2015, 11, 12, 18, 30))
    end
  end

  context '#coach_spaces?' do
    let(:sponsor) { Fabricate(:sponsor) }
    let(:workshop) { Fabricate(:workshop_no_sponsor) }

    before do
      Fabricate(:workshop_sponsor, sponsor: sponsor, workshop: workshop, host: true)
    end
  end

  context '#rsvp_available?' do
    context 'rsvp is available' do
      it 'when the event is in the future' do
        workshop.date_and_time = 1.day.from_now
        workshop.save

        expect(workshop.rsvp_available?).to be(true)
      end

      it 'when rsvp_close_time is in the future' do
        workshop.rsvp_close_time = 2.hours.from_now

        expect(workshop.rsvp_available?).to be(true)
      end
    end

    context 'rsvp is not available' do
      it 'when the rsvp_close_time is in the past' do
        workshop.rsvp_close_time = 2.hours.ago

        expect(workshop.rsvp_available?).to be(false)
      end
    end
  end

  context '#scopes' do
    let(:set_upcoming) { 2.times.map { |n| Fabricate(:workshop, date_and_time: Time.zone.now + (n + 1).week) } }
    let(:most_recent) { Fabricate(:workshop, date_and_time: 1.day.ago) }

    before do
      @old_workshop = Fabricate(:workshop, date_and_time: Time.zone.now - 1.week)
      set_upcoming
      most_recent
    end

    it '#upcoming' do
      expect(Workshop.upcoming.length).to eq(2)
    end

    it '#next' do
      expect(Workshop.next).to eq(set_upcoming.first)
    end

    it '#most_recent' do
      expect(Workshop.most_recent).to eq(most_recent)
    end

    describe '#host' do
      let(:sponsor) { Fabricate(:sponsor) }

      before do
        workshop.workshop_sponsors.delete_all
        Fabricate(:workshop_sponsor, sponsor: sponsor, workshop: workshop, host: true)
      end

      it { expect(workshop.host).to eq(sponsor) }
    end

    context 'attendances' do
      let(:sponsor) { Fabricate(:sponsor) }

      before do
        Fabricate(:workshop_sponsor, sponsor: sponsor, workshop: workshop, host: true)
      end

      it '#attending_students' do
        3.times { Fabricate(:session_invitation, workshop: workshop, attending: true) }
        1.times { Fabricate(:session_invitation, workshop: workshop, attending: false) }

        expect(workshop.reload.attending_students.length).to eq(3)
      end

      it '#attending_members' do
        2.times { Fabricate(:coach_session_invitation, workshop: workshop, attending: true) }
        1.times { Fabricate(:coach_session_invitation, workshop: workshop, attending: false) }

        expect(workshop.reload.attending_coaches.length).to eq(2)
      end

      it '#attendee? for students' do
        attendee_invites = 4.times.collect { Fabricate(:session_invitation, workshop: workshop, attending: true) }
        nonattendee_invites = 2.times.collect { Fabricate(:session_invitation, workshop: workshop, attending: false) }

        attendee_invites.each { |a| expect(workshop.attendee? a.member).to be true }
        nonattendee_invites.each { |a| expect(workshop.attendee? a.member).to be false }
      end

      it '#attendee? for coaches' do
        attendee_invites = 4.times.collect { Fabricate(:coach_session_invitation, workshop: workshop, attending: true) }
        nonattendee_invites = 2.times.collect { Fabricate(:coach_session_invitation, workshop: workshop, attending: false) }

        attendee_invites.each { |a| expect(workshop.attendee? a.member).to be true }
        nonattendee_invites.each { |a| expect(workshop.attendee? a.member).to be false }
      end
    end

    context 'Waitlist attendance' do
      it '#waitlisted? for students' do
        invitations = 5.times.collect { Fabricate(:session_invitation, workshop: workshop) }
        invitations.each { |invitation| WaitingList.add(invitation) }
        attendee_invites = 4.times.collect { Fabricate(:session_invitation, workshop: workshop, attending: true) }

        invitations.each { |a| expect(workshop.waitlisted? a.member).to be true }
        attendee_invites.each { |a| expect(workshop.waitlisted? a.member).to be false }
      end

      it '#waitlisted? for coaches' do
        invitations = 5.times.collect { Fabricate(:coach_session_invitation, workshop: workshop) }
        invitations.each { |invitation| WaitingList.add(invitation) }
        attendee_invites = 4.times.collect { Fabricate(:coach_session_invitation, workshop: workshop, attending: true) }

        invitations.each { |a| expect(workshop.waitlisted? a.member).to be true }
        attendee_invites.each { |a| expect(workshop.waitlisted? a.member).to be false }
      end
    end

    describe '.recent' do
      it 'retrieves some of the most recently held workshops' do
        expect(Workshop.recent).to eq([most_recent, @old_workshop])
      end
    end
  end

  context '#invitable_yet?' do
    it 'is invitable if invitable set to true, no RSVP open time/date set' do
      workshop = Fabricate.build(:workshop, chapter: Fabricate(:chapter), invitable: true)
      expect(workshop.invitable_yet?).to be true
    end

    it 'is invitable if RSVP open date/time in past, and invitable set to false' do
      workshop = Fabricate.build(:workshop, chapter: Fabricate(:chapter), invitable: false, rsvp_open_time: Time.zone.now - 1.days)
      expect(workshop.invitable_yet?).to be true
    end

    it 'is invitable if RSVP open date/time in future, and invitable set to true' do
      workshop = Fabricate.build(:workshop, chapter: Fabricate(:chapter), invitable: true, rsvp_open_time: Time.zone.now - 1.days)
      expect(workshop.invitable_yet?).to be true
    end

    it 'is NOT invitable if RSVP open date/time in future, and invitable set to false' do
      workshop = Fabricate.build(:workshop, chapter: Fabricate(:chapter), invitable: false, rsvp_open_time: Time.zone.now + 1.days)
      expect(workshop.invitable_yet?).to be false
    end
  end
end
