RSpec.describe WorkshopInvitationMailer do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:workshop) { Fabricate(:workshop, title: 'HTML & CSS') }
  let(:member) { Fabricate(:member) }
  let(:invitation) { Fabricate(:workshop_invitation, workshop: workshop, member: member) }
  let(:sponsor) { Fabricate(:sponsor) }

  it '#attending' do
    email_subject = "Attendance Confirmation for #{humanize_date(workshop.date_and_time, with_time: true)}"

    WorkshopInvitationMailer.attending(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(workshop.chapter.email)
  end

  it '#attending_reminder' do
    email_subject = "Workshop Reminder #{humanize_date(workshop.date_and_time, with_time: true)}"

    WorkshopInvitationMailer.attending_reminder(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(workshop.chapter.email)
  end

  it '#invite_coach' do
    email_subject = "Workshop Coach Invitation #{humanize_date(workshop.date_and_time, with_time: true)}"

    WorkshopInvitationMailer.invite_coach(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(workshop.chapter.email)
  end

  it '#invite_student' do
    email_subject = "Workshop Invitation #{humanize_date(workshop.date_and_time, with_time: true)}"

    WorkshopInvitationMailer.invite_student(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(workshop.chapter.email)
  end

  it '#notify_waiting_list' do
    WorkshopInvitationMailer.notify_waiting_list(invitation).deliver_now

    expect(email.subject).to eq('A spot just became available')
    expect(email.from).to eq([workshop.chapter.email])
    expect(email.body.encoded).to match('A spot just opened up for you at the workshop')
  end

  it '#waitlist_reminder' do
    email_subject = "Reminder: you're on the codebar waiting list " \
                    "(#{humanize_date(workshop.date_and_time, with_time: true)})"

    WorkshopInvitationMailer.waiting_list_reminder(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.from).to eq([workshop.chapter.email])
    expect(email.body.encoded).to match("the workshop on #{humanize_date(workshop.date_and_time, with_time: true)}")
    expect(email.body.encoded).to match(workshop.chapter.email)
  end

  it '#attending includes the workshop description' do
    description = "This is a test workshop description."
    workshop = Fabricate(:workshop, description: description)
    invitation = Fabricate(:workshop_invitation, workshop: workshop, member: member)

    WorkshopInvitationMailer.attending(workshop, member, invitation).deliver_now

    expect(email.body.encoded).to include(description)
  end
end
