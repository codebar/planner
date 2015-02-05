require 'spec_helper'

describe InvitationManager do

  let(:chapter) { Fabricate(:chapter) }
  let(:students) { Fabricate(:students, chapter: chapter) }
  let(:coaches) { Fabricate(:coaches, chapter: chapter) }
  let!(:session) { Fabricate(:sessions, chapter: chapter) }

  let(:student) { Fabricate(:student, groups: [ students ]) }

  it "#send_session_emails" do
    expect(chapter.groups).to receive(:students).and_return([students])
    expect(chapter.groups).to receive(:coaches).and_return([coaches])

    expect(students.members.count).to be > 0
    students.members.each do |student|
      expect(SessionInvitation).to receive(:create).with(sessions: session, member: student, role: "Student").and_call_original
    end

    InvitationManager.send_session_emails session
  end

  it "Sends emails when a SessionInvitation is created" do
    expect(chapter.groups).to receive(:students).and_return([students])
    expect(chapter.groups).to receive(:coaches).and_return([coaches])

    expect {
      InvitationManager.send_session_emails session
    }.to change { ActionMailer::Base.deliveries.count }
  end

  it "Doesn't send emails when it's not created" do
    expect(chapter.groups).to receive(:students).and_return([students])
    expect(SessionInvitation).to receive(:create).at_least(:once).and_return(SessionInvitation.new)

    expect {
      InvitationManager.send_session_emails session
    }.not_to change { ActionMailer::Base.deliveries.count }
  end

  it "#send_course_emails" do
    course = Fabricate(:course)
    expect(course.chapter.groups).to receive(:students).and_return([students])

    students.members.each do |student|
      expect(CourseInvitation).to receive(:create).with(course: course, member: student)
    end

    InvitationManager.send_course_emails course
  end

  it "#send_event_emails" do
    event = Fabricate(:event)
    chapter = Fabricate(:chapter_with_groups)
    expect(chapter.groups).to receive(:students).and_return([students])
    expect(chapter.groups).to receive(:coaches).and_return([coaches])

    students.members.each do |student|
      expect(Invitation).to receive(:new).with(event: event, member: student, role: "Student").and_call_original
    end

    coaches.members.each do |student|
      expect(Invitation).to receive(:new).with(event: event, member: student, role: "Coach").and_call_original
    end

    InvitationManager.send_event_emails(event, chapter)
  end

  describe "Attendance reminders" do
    # Create a workshop with 30 invites: 10 attendees, 10 waitlisted places, 10 people not coming.
    before(:example) do
      ActionMailer::Base.deliveries = [] # Start with no emails sent before each test.
      populace = 30.times.map {Fabricate(:member) }.shuffle
      @attending_students = populace.shift(5)
      @attending_coaches = populace.shift(5)
      @waitlisted_students = populace.shift(5)
      @waitlisted_coaches = populace.shift(5)
      @absent_students = populace.shift(5)
      @absent_coaches = populace.shift(5)
      @workshop = Fabricate(:sessions)
      @attending_students.each {|as| Fabricate(:student_session_invitation, attending: true, sessions: @workshop, member: as) }
      @attending_coaches.each {|ac| Fabricate(:coach_session_invitation, attending: true, sessions: @workshop, member: ac) }
      @absent_students.each {|as| Fabricate(:student_session_invitation, sessions: @workshop, member: as) }
      @absent_coaches.each {|ac| Fabricate(:coach_session_invitation, sessions: @workshop, member: ac) }
      @waitlisted_students.each do |ws|
        invite = Fabricate(:student_session_invitation, sessions: @workshop, member: ws)
        WaitingList.add(invite)
      end
      @waitlisted_coaches.each do |wc|
        invite = Fabricate(:coach_session_invitation, sessions: @workshop, member: wc)
        WaitingList.add(invite)
      end
    end

    it "Sets up the workshop as expected" do
      expect(@workshop.attendances.length).to eql 10
      expect(@workshop.waiting_list.length).to eql 10

      (@attending_students + @attending_coaches).each do |member|
        expect(@workshop.attendee? member).to be true
        expect(@workshop.waitlisted? member).to be false
      end

      (@waitlisted_students + @waitlisted_coaches).each do |member|
        expect(@workshop.attendee? member).to be false
        expect(@workshop.waitlisted? member).to be true
      end

      (@absent_students + @absent_coaches).each do |member|
        expect(@workshop.attendee? member).to be false
        expect(@workshop.waitlisted? member).to be false
      end
    end

    it "sends out attendance reminders to attendees, and no-one else" do
      expect {
        InvitationManager.send_workshop_attendance_reminders(@workshop)
      }.to change { ActionMailer::Base.deliveries.count }.by 10

      ActionMailer::Base.deliveries.each do |mail|
        expect((@attending_students + @attending_coaches).one? {|p| mail.to.include? p.email}).to be true
        expect(@waitlisted_students.none? {|p| p.email == mail.to}).to be true
        expect(@waitlisted_coaches.none? {|p| p.email == mail.to}).to be true
        expect(@absent_coaches.none? {|p| p.email == mail.to}).to be true
        expect(@absent_coaches.none? {|p| p.email == mail.to}).to be true
      end
    end

    it "sends out waitlist reminders to waitlisted people only, and no-one else" do
      expect {
        InvitationManager.send_workshop_waiting_list_reminders(@workshop)
      }.to change { ActionMailer::Base.deliveries.count }.by 10

      ActionMailer::Base.deliveries.each do |mail|
        expect(@attending_students.none? {|p| p.email == mail.to}).to be true
        expect(@attending_coaches.none? {|p| p.email == mail.to}).to be true
        expect((@waitlisted_students + @waitlisted_coaches).one? {|p| mail.to.include? p.email}).to be true
        expect(@absent_coaches.none? {|p| p.email == mail.to}).to be true
        expect(@absent_coaches.none? {|p| p.email == mail.to}).to be true
      end
    end
  end
end
