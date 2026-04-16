RSpec.shared_examples 'sending workshop emails' do
  it 'creates an invitation for each student' do
    Fabricate(:students, chapter: chapter, members: students)

    students.each do |student|
      expect(WorkshopInvitation).to receive(:find_or_initialize_by).with(workshop: workshop, member: student, role: 'Student').and_call_original
      expect(mailer).to receive(:invite_student).and_call_original
    end

    manager.send(send_email, workshop, 'students')
  end

  it 'creates an invitation for each coach' do
    Fabricate(:coaches, chapter: chapter, members: coaches)

    coaches.each do |coach|
      expect(WorkshopInvitation).to receive(:find_or_initialize_by).with(workshop: workshop, member: coach, role: 'Coach').and_call_original
      expect(mailer).to receive(:invite_coach).and_call_original
    end

    manager.send(send_email, workshop, 'coaches')
  end

  it 'does not invite banned coaches' do
    banned_coach = Fabricate(:banned_member)
    Fabricate(:coaches, chapter: chapter, members: coaches + [banned_coach])

    coaches.each do |coach|
      expect(WorkshopInvitation).to receive(:find_or_initialize_by).with(workshop: workshop, member: coach, role: 'Coach').and_call_original
    end
    expect(WorkshopInvitation).not_to receive(:find_or_initialize_by).with(workshop: workshop, member: banned_coach, role: 'Coach')

    manager.send(send_email, workshop, 'coaches')
  end

  it 'sends emails when a WorkshopInvitation is created' do
    Fabricate(:students, chapter: chapter, members: students)
    Fabricate(:coaches, chapter: chapter, members: coaches)

    expect do
      manager.send(send_email, workshop, 'everyone')
    end.to change { ActionMailer::Base.deliveries.count }.by(students.count + coaches.count)
  end

  it 'does not send emails when invitation creation returns nil' do
    Fabricate(:students, chapter: chapter, members: students)

    expect(WorkshopInvitation).to receive(:find_or_initialize_by).and_return(nil).exactly(students.count)

    expect do
      manager.send(send_email, workshop, 'students')
    end.not_to(change { ActionMailer::Base.deliveries.count })
  end

  it 'does not send duplicate emails when members are already invited' do
    Fabricate(:students, chapter: chapter, members: students)

    # First invitation round - creates invitations and sends emails
    manager.send(send_email, workshop, 'students')

    # Clear deliveries to track second round
    ActionMailer::Base.deliveries.clear

    # Second invitation round - should not send duplicate emails
    expect do
      manager.send(send_email, workshop, 'students')
    end.not_to(change { ActionMailer::Base.deliveries.count })
  end
end
