require 'spec_helper'

describe InvitationManager do
  let(:chapter)   { Fabricate(:chapter) }
  let(:students)  { Fabricate(:students, chapter: chapter) }
  let(:coaches)   { Fabricate(:coaches, chapter: chapter) }
  let!(:workshop) { Fabricate(:workshop, chapter: chapter) }

  let(:student) { Fabricate(:student, groups: [students]) }

  describe '#send_workshop_emails' do
    subject(:manager) { InvitationManager.new }

    it 'creates an invitation for each student' do
      expect(chapter.groups).to receive(:students).and_return([students])

      expect(students.members.count).to be > 0

      students.members.each do |student|
        expect(WorkshopInvitation).to receive(:create).with(workshop: workshop, member: student, role: 'Student').and_call_original
      end

      manager.send_workshop_emails(workshop, 'students')
    end

    it 'creates an invitation for each coach' do
      allow(chapter.groups).to receive_messages(coaches: [coaches])

      manager.send_workshop_emails(workshop, 'coaches')

      coach_invites = WorkshopInvitation.where(role: 'Coach')

      expect(coach_invites.count).to eq 5
    end

    it 'does not invite banned coaches' do
      banned_coach = coaches.members.second

      allow(banned_coach).to receive_messages(banned?: true)
      allow(chapter.groups).to receive_messages(coaches: [coaches])

      manager.send_workshop_emails(workshop, 'everyone')

      coach_invites = WorkshopInvitation.where(role: 'Coach')

      expect(coach_invites.count).to eq 4

      expect(coach_invites.where(member: banned_coach)).to be_empty
    end

    it 'Sends emails when a WorkshopInvitation is created' do
      expect(chapter.groups).to receive(:students).and_return([students])
      expect(chapter.groups).to receive(:coaches).and_return([coaches])

      expect {
        InvitationManager.new.send_workshop_emails(workshop, 'everyone')
      }.to change { ActionMailer::Base.deliveries.count }
    end

    it "Doesn't send emails when it's not created" do
      expect(chapter.groups).to receive(:students).and_return([students])
      expect(WorkshopInvitation).to receive(:create).at_least(:once).and_return(MeetingInvitation.new)

      expect {
        InvitationManager.new.send_workshop_emails(workshop, 'students')
      }.not_to change { ActionMailer::Base.deliveries.count }
    end
  end

  it '#send_course_emails' do
    course = Fabricate(:course)
    invitation = Fabricate(:course_invitation)
    expect(course.chapter.groups).to receive(:students).and_return([students])

    students.members.each do |student|
      expect(CourseInvitation).to receive(:new).with(course: course, member: student).and_return(invitation)
    end

    InvitationManager.send_course_emails course
  end

  it '#send_event_emails' do
    event = Fabricate(:event, chapters: [chapter])
    event.chapters.each do |chapter|
      expect(chapter.groups).to receive(:coaches).and_return([coaches])
      expect(chapter.groups).to receive(:students).and_return([students])
    end

    students.members.each do |student|
      expect(Invitation).to receive(:new).with(event: event, member: student, role: 'Student').and_call_original
    end

    coaches.members.each do |student|
      expect(Invitation).to receive(:new).with(event: event, member: student, role: 'Coach').and_call_original
    end

    InvitationManager.new.send_event_emails(event, chapter)
  end

  describe 'Attendance reminders' do
    before(:example) do
      ActionMailer::Base.deliveries = []
      populace = 12.times.map { Fabricate(:member) }.shuffle
      @attending_students = populace.shift(2)
      @attending_coaches = populace.shift(2)
      @waitlisted_students = populace.shift(2)
      @waitlisted_coaches = populace.shift(2)
      @absent_students = populace.shift(2)
      @absent_coaches = populace.shift(2)
      @workshop = Fabricate(:workshop)
      @attending_students.each { |as| Fabricate(:student_workshop_invitation, attending: true, workshop: @workshop, member: as) }
      @attending_coaches.each { |ac| Fabricate(:coach_workshop_invitation, attending: true, workshop: @workshop, member: ac) }
      @absent_students.each { |as| Fabricate(:student_workshop_invitation, workshop: @workshop, member: as) }
      @absent_coaches.each { |ac| Fabricate(:coach_workshop_invitation, workshop: @workshop, member: ac) }
      @waitlisted_students.each do |ws|
        invite = Fabricate(:student_workshop_invitation, workshop: @workshop, member: ws)
        WaitingList.add(invite)
      end
      @waitlisted_coaches.each do |wc|
        invite = Fabricate(:coach_workshop_invitation, workshop: @workshop, member: wc)
        WaitingList.add(invite)
      end
    end

    it 'Sets up the workshop as expected' do
      expect(@workshop.attendances.length).to eql 4
      expect(@workshop.waiting_list.length).to eql 4

      (@attending_students + @attending_coaches).each do |member|
        expect(@workshop.attendee?(member)).to be true
        expect(@workshop.waitlisted?(member)).to be false
      end

      (@waitlisted_students + @waitlisted_coaches).each do |member|
        expect(@workshop.attendee?(member)).to be false
        expect(@workshop.waitlisted?(member)).to be true
      end

      (@absent_students + @absent_coaches).each do |member|
        expect(@workshop.attendee?(member)).to be false
        expect(@workshop.waitlisted?(member)).to be false
      end
    end

    it 'sends out attendance reminders to attendees, and no-one else' do
      expect {
        InvitationManager.send_workshop_attendance_reminders(@workshop)
      }.to change { ActionMailer::Base.deliveries.count }.by 4

      ActionMailer::Base.deliveries.each do |mail|
        expect((@attending_students + @attending_coaches).one? { |p| mail.to.include? p.email }).to be true
        expect(@waitlisted_students.none? { |p| p.email == mail.to }).to be true
        expect(@waitlisted_coaches.none? { |p| p.email == mail.to }).to be true
        expect(@absent_coaches.none? { |p| p.email == mail.to }).to be true
        expect(@absent_coaches.none? { |p| p.email == mail.to }).to be true
      end
    end

    it 'sends out waitlist reminders to waitlisted people only, and no-one else' do
      expect {
        InvitationManager.send_workshop_waiting_list_reminders(@workshop)
      }.to change { ActionMailer::Base.deliveries.count }.by 4

      ActionMailer::Base.deliveries.each do |mail|
        expect(@attending_students.none? { |p| p.email == mail.to }).to be true
        expect(@attending_coaches.none? { |p| p.email == mail.to }).to be true
        expect((@waitlisted_students + @waitlisted_coaches).one? { |p| mail.to.include? p.email }).to be true
        expect(@absent_coaches.none? { |p| p.email == mail.to }).to be true
        expect(@absent_coaches.none? { |p| p.email == mail.to }).to be true
      end
    end
  end
end
