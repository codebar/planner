require 'spec_helper'

describe InvitationManager, wip: true do
  let(:chapter)   { Fabricate(:chapter) }
  let(:workshop) { Fabricate(:workshop, chapter: chapter) }
  let(:students) { Fabricate.times(3, :member) }
  let(:coaches) { Fabricate.times(6, :member) }

  describe '#send_workshop_emails' do
    subject(:manager) { InvitationManager.new }

    it 'creates an invitation for each student' do
      student_group = Fabricate(:students, chapter: chapter, members: students)

      students.each do |student|
        expect(WorkshopInvitation).to receive(:create).with(workshop: workshop, member: student, role: 'Student').and_call_original
        expect(WorkshopInvitationMailer).to receive(:invite_student).and_call_original
      end

      manager.send_workshop_emails(workshop, 'students')
    end

    it 'creates an invitation for each coach' do
      coach_group = Fabricate(:coaches, chapter: chapter, members: coaches)

      coaches.each do |coach|
        expect(WorkshopInvitation).to receive(:create).with(workshop: workshop, member: coach, role: 'Coach').and_call_original
        expect(WorkshopInvitationMailer).to receive(:invite_coach).and_call_original
      end

      manager.send_workshop_emails(workshop, 'coaches')
    end

    it 'does not invite banned coaches' do
      banned_coach = Fabricate(:banned_member)
      coach_group = Fabricate(:coaches, chapter: chapter, members: coaches + [banned_coach])

      manager.send_workshop_emails(workshop, 'everyone')

      coaches.each do |coach|
        expect(WorkshopInvitation).to receive(:create).with(workshop: workshop, member: coach, role: 'Coach').and_call_original
      end
      expect(WorkshopInvitation).to_not receive(:create).with(workshop: workshop, member: banned_coach, role: 'Coach')
      manager.send_workshop_emails(workshop, 'coaches')
    end

    it 'Sends emails when a WorkshopInvitation is created' do
      student_group = Fabricate(:students, chapter: chapter, members: students)
      coach_group = Fabricate(:coaches, chapter: chapter, members: coaches)

      expect {
        InvitationManager.new.send_workshop_emails(workshop, 'everyone')
      }.to change { ActionMailer::Base.deliveries.count }.by(students.count + coaches.count)
    end

    it "does not send emails when no invitation is created" do
      student_group = Fabricate(:students, chapter: chapter, members: students)

      students.count.times { expect(WorkshopInvitation).to receive(:create).and_return(WorkshopInvitation.new) }

      expect {
        InvitationManager.new.send_workshop_emails(workshop, 'students')
      }.not_to change { ActionMailer::Base.deliveries.count }
    end
  end

  it '#send_course_emails' do
    course = Fabricate(:course, chapter: chapter)
    invitation = Fabricate(:course_invitation)
    students = Fabricate.times(2, :member)
    student_group = Fabricate(:students, chapter: chapter, members: students)

    students.each do |student|
      expect(CourseInvitation).to receive(:new).with(course: course, member: student).and_return(invitation)
    end

    InvitationManager.send_course_emails course
  end

  it '#send_event_emails' do
    chapter = Fabricate(:chapter)
    student_group = Fabricate(:students, chapter: chapter, members: students)
    coaches_group = Fabricate(:coaches, chapter: chapter, members: coaches)
    event = Fabricate(:event, chapters: [chapter])

    students.each do |student|
      expect(Invitation).to receive(:new).with(event: event, member: student, role: 'Student').and_call_original
    end

    coaches.each do |student|
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
