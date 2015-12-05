require 'spec_helper'

describe Sessions do
  subject(:session) { Fabricate(:sessions) }

  it { should respond_to(:title) }
  it { should respond_to(:description) }
  it { should respond_to(:date_and_time) }
  it { should respond_to(:sponsors) }
  it { should respond_to(:sponsor_sessions)}

  context "#before_save" do
    let(:workshop) { Fabricate.build(:sessions, chapter: Fabricate(:chapter)) }

    it "merges date_and_time and time" do
      workshop.date_and_time = Time.zone.local(2015,11,12,12,0)
      workshop.time = Time.utc(2000,01,01,18,30)

      workshop.save

      expect(workshop.date_and_time).to eq(Time.zone.local(2015,11,12,18,30))
    end
  end

  context "#coach_spaces?" do
    let(:sponsor) { Fabricate(:sponsor) }
    let(:session) { Fabricate(:sessions_no_sponsor) }

    before do
      Fabricate(:sponsor_session, sponsor: sponsor, sessions: session, host: true)
    end
  end

  context "#rsvp_available?" do
    context "rsvp is available" do
      it "when the event is in the future" do
        session.date_and_time = 1.day.from_now
        session.save

        expect(session.rsvp_available?).to be(true)
      end

      it "when rsvp_close_time is in the future" do
        session.rsvp_close_time = 2.hours.from_now

        expect(session.rsvp_available?).to be(true)
      end
    end

    context "rsvp is not available" do

      it "when the rsvp_close_time is in the past" do
        session.rsvp_close_time = 2.hours.ago

        expect(session.rsvp_available?).to be(false)
      end
    end
  end

  context "#scopes" do
    let(:set_upcoming) { 2.times.map { |n| Fabricate(:sessions, date_and_time: Time.zone.now+(n+1).week) } }
    let(:most_recent) { Fabricate(:sessions, date_and_time: 1.day.ago) }

    before do
      Fabricate(:sessions, date_and_time: Time.zone.now-1.week)
      set_upcoming
      most_recent
    end

    it "#upcoming" do
      expect(Sessions.upcoming.length).to eq(2)
    end

    it "#next" do
      expect(Sessions.next).to eq(set_upcoming.first)
    end

    it "#most_recent" do
      expect(Sessions.most_recent).to eq(most_recent)
    end

    describe "#host" do
      let(:sponsor) { Fabricate(:sponsor) }

      before do
        session.sponsor_sessions.delete_all
        Fabricate(:sponsor_session, sponsor: sponsor, sessions: session, host: true)
      end

      it { expect(session.host).to eq(sponsor) }
    end

    context "attendances" do
      let(:sponsor) { Fabricate(:sponsor) }

      before do
        Fabricate(:sponsor_session, sponsor: sponsor, sessions: session, host: true)
      end

      it "#attending_students" do
        3.times { Fabricate(:session_invitation, sessions: session, attending: true) }
        1.times { Fabricate(:session_invitation, sessions: session, attending: false) }

        expect(session.reload.attending_students.length).to eq(3)
      end

      it "#attending_members" do
        2.times { Fabricate(:coach_session_invitation, sessions: session, attending: true) }
        1.times { Fabricate(:coach_session_invitation, sessions: session, attending: false) }

        expect(session.reload.attending_coaches.length).to eq(2)
      end

      it "#attendee? for students" do
        attendee_invites = 4.times.collect { Fabricate(:session_invitation, sessions: session, attending: true) }
        nonattendee_invites = 2.times.collect { Fabricate(:session_invitation, sessions: session, attending: false) }

        attendee_invites.each {|a| expect(session.attendee? a.member).to be true }
        nonattendee_invites.each {|a| expect(session.attendee? a.member).to be false }
      end

      it "#attendee? for coaches" do
        attendee_invites = 4.times.collect { Fabricate(:coach_session_invitation, sessions: session, attending: true) }
        nonattendee_invites = 2.times.collect { Fabricate(:coach_session_invitation, sessions: session, attending: false) }

        attendee_invites.each {|a| expect(session.attendee? a.member).to be true }
        nonattendee_invites.each {|a| expect(session.attendee? a.member).to be false }
      end
    end

    context "Waitlist attendance" do
      it "#waitlisted? for students" do
        invitations = 5.times.collect { Fabricate(:session_invitation, sessions: session) }
        invitations.each { |invitation| WaitingList.add(invitation) }
        attendee_invites = 4.times.collect { Fabricate(:session_invitation, sessions: session, attending: true) }

        invitations.each {|a| expect(session.waitlisted? a.member).to be true }
        attendee_invites.each {|a| expect(session.waitlisted? a.member).to be false }
      end

      it "#waitlisted? for coaches" do
        invitations = 5.times.collect { Fabricate(:coach_session_invitation, sessions: session) }
        invitations.each { |invitation| WaitingList.add(invitation) }
        attendee_invites = 4.times.collect { Fabricate(:coach_session_invitation, sessions: session, attending: true) }

        invitations.each {|a| expect(session.waitlisted? a.member).to be true }
        attendee_invites.each {|a| expect(session.waitlisted? a.member).to be false }
      end
    end
  end
end
