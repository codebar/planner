RSpec.shared_examples 'sending workshop emails' do
  it 'creates an invitation for each student' do
    student_group = Fabricate(:students, chapter: chapter, members: students)

    students.each do |student|
      expect(WorkshopInvitation).to receive(:create).with(workshop: workshop, member: student, role: 'Student').and_call_original
      expect(mailer).to receive(:invite_student).and_call_original
    end

    manager.send(send_email, workshop, 'students')
  end

  it 'creates an invitation for each coach' do
    coach_group = Fabricate(:coaches, chapter: chapter, members: coaches)

    coaches.each do |coach|
      expect(WorkshopInvitation).to receive(:create).with(workshop: workshop, member: coach, role: 'Coach').and_call_original
      expect(mailer).to receive(:invite_coach).and_call_original
    end

    manager.send(send_email, workshop, 'coaches')
  end

  it 'does not invite banned coaches' do
    banned_coach = Fabricate(:banned_member)
    coach_group = Fabricate(:coaches, chapter: chapter, members: coaches + [banned_coach])

    coaches.each do |coach|
      expect(WorkshopInvitation).to receive(:create).with(workshop: workshop, member: coach, role: 'Coach').and_call_original
    end
    expect(WorkshopInvitation).to_not receive(:create).with(workshop: workshop, member: banned_coach, role: 'Coach')

    manager.send(send_email, workshop, 'coaches')
  end

  it 'sends emails when a WorkshopInvitation is created' do
    student_group = Fabricate(:students, chapter: chapter, members: students)
    coach_group = Fabricate(:coaches, chapter: chapter, members: coaches)

    expect do
      manager.send(send_email, workshop, 'everyone')
    end.to change { ActionMailer::Base.deliveries.count }.by(students.count + coaches.count)
  end

  it "does not send emails when no invitation is created" do
    student_group = Fabricate(:students, chapter: chapter, members: students)

    expect(WorkshopInvitation).to receive(:create).and_return(WorkshopInvitation.new).exactly(students.count)

    expect do
      manager.send(send_email, workshop, 'students')
    end.not_to change { ActionMailer::Base.deliveries.count }
  end
end
