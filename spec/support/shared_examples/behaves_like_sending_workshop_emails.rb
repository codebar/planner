RSpec.shared_examples 'sending workshop emails' do
  it 'creates an invitation for each student and sends emails' do
    Fabricate(:students, chapter:, members: students)

    students.each do |student|
      allow(WorkshopInvitation).to receive(:find_or_create_by!).with(workshop:, member: student).and_call_original
    end

    expect do
      manager.send(send_email, workshop, 'students')
    end.to change { ActionMailer::Base.deliveries.count }.by(students.count)
                                                         .and change { WorkshopInvitation.where(workshop:, role: 'Student').count }.by(students.count)

    students.each do |student|
      expect(WorkshopInvitation).to have_received(:find_or_create_by!).with(workshop:, member: student)
    end

    # Verify emails were sent to the right recipients
    emails = ActionMailer::Base.deliveries.last(students.count)
    student_emails = students.map(&:email)
    expect(emails.map(&:to).flatten).to match_array(student_emails)
  end

  it 'creates an invitation for each coach and sends emails' do
    Fabricate(:coaches, chapter:, members: coaches)

    coaches.each do |coach|
      allow(WorkshopInvitation).to receive(:find_or_create_by!).with(workshop:, member: coach).and_call_original
    end

    expect do
      manager.send(send_email, workshop, 'coaches')
    end.to change { ActionMailer::Base.deliveries.count }.by(coaches.count)
                                                         .and change { WorkshopInvitation.where(workshop:, role: 'Coach').count }.by(coaches.count)

    coaches.each do |coach|
      expect(WorkshopInvitation).to have_received(:find_or_create_by!).with(workshop:, member: coach)
    end

    # Verify emails were sent to the right recipients
    emails = ActionMailer::Base.deliveries.last(coaches.count)
    coach_emails = coaches.map(&:email)
    expect(emails.map(&:to).flatten).to match_array(coach_emails)
  end

  it 'does not invite banned coaches' do
    banned_coach = Fabricate(:banned_member)
    Fabricate(:coaches, chapter:, members: coaches + [banned_coach])

    coaches.each do |coach|
      allow(WorkshopInvitation).to receive(:find_or_create_by!).with(workshop:, member: coach).and_call_original
    end

    manager.send(send_email, workshop, 'coaches')

    coaches.each do |coach|
      expect(WorkshopInvitation).to have_received(:find_or_create_by!).with(workshop:, member: coach)
    end
    expect(WorkshopInvitation).not_to have_received(:find_or_create_by!).with(workshop:, member: banned_coach)
  end

  it 'sends emails when a WorkshopInvitation is created' do
    Fabricate(:students, chapter:, members: students)
    Fabricate(:coaches, chapter:, members: coaches)

    expect do
      manager.send(send_email, workshop, 'everyone')
    end.to change { ActionMailer::Base.deliveries.count }.by(students.count + coaches.count)
  end

  it 'does not send emails when invitation creation returns nil' do
    Fabricate(:students, chapter:, members: students)

    allow(WorkshopInvitation).to receive(:find_or_create_by!).and_return(nil).exactly(students.count)

    expect do
      manager.send(send_email, workshop, 'students')
    end.not_to(change { ActionMailer::Base.deliveries.count })

    expect(WorkshopInvitation).to have_received(:find_or_create_by!).exactly(students.count).times
  end

  it 'passes chapter_id and workshop_date to the mailer so job log lines carry them' do
    Fabricate(:students, chapter:, members: students)
    Fabricate(:coaches, chapter:, members: coaches)

    context_hash = { chapter_id: workshop.chapter_id, workshop_date: workshop.date_and_time.utc.to_date.iso8601 }

    allow(mailer).to receive(:invite_student).and_call_original
    allow(mailer).to receive(:invite_coach).and_call_original

    manager.send(send_email, workshop, 'everyone')

    expect(mailer).to have_received(:invite_student).with(workshop, anything, anything, context_hash).at_least(:once)
    expect(mailer).to have_received(:invite_coach).with(workshop, anything, anything, context_hash).at_least(:once)
  end

  it 'keeps log_context intact through the enqueued delivery job' do
    student = Fabricate(:member)
    invitation = Fabricate(:workshop_invitation, workshop:, member: student)

    context_hash = { chapter_id: workshop.chapter_id, workshop_date: workshop.date_and_time.utc.to_date.iso8601 }

    begin
      original = Delayed::Worker.delay_jobs
      Delayed::Worker.delay_jobs = true

      mailer.invite_student(workshop, student, invitation, context_hash).deliver_later

      job_rows = Delayed::Job.all
      expect(job_rows).not_to be_empty

      job_rows.each do |row|
        arguments = row.payload_object.job_data['arguments']

        expect(arguments.first).to eq(mailer.name)
        expect(arguments[1]).to eq('invite_student')

        deserialized_mail_args = ActiveJob::Arguments.deserialize(arguments[3]['args'])
        expect(deserialized_mail_args.last).to eq(context_hash)
      end
    ensure
      Delayed::Worker.delay_jobs = original
    end
  end

  it 'does not send duplicate emails when members are already invited' do
    Fabricate(:students, chapter:, members: students)

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
