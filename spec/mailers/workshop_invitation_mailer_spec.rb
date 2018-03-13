require 'spec_helper'

describe WorkshopInvitationMailer do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:workshop) { Fabricate(:workshop, title: 'HTML & CSS') }
  let(:member) { Fabricate(:member) }
  let(:invitation) { Fabricate(:workshop_invitation, workshop: workshop, member: member) }

  it '#invite_student' do
    email_subject = "Workshop Invitation #{humanize_date(workshop.date_and_time, with_time: true)}"
    WorkshopInvitationMailer.invite_student(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(workshop.chapter.email)
  end

  it '#attending_reminder' do
    email_subject = "Workshop Reminder #{humanize_date(workshop.date_and_time, with_time: true)}"
    WorkshopInvitationMailer.attending_reminder(workshop, member, invitation).deliver_now
    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(workshop.chapter.email)
  end

  it '#waitlist_reminder' do
    email_subject = "Reminder: you're on the codebar waiting list (#{humanize_date(workshop.date_and_time, with_time: true)})"
    WorkshopInvitationMailer.waiting_list_reminder(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.from).to eq([workshop.chapter.email])
    expect(email.body.encoded).to match('you should keep your laptop with you and check your email during the afternoon on the day of the workshop.')
    expect(email.body.encoded).to match("This is a quick email to remind you that you're on the waiting list for the workshop on #{humanize_date(workshop.date_and_time, with_time: true)}")
    expect(email.body.encoded).to match(workshop.chapter.email)
  end
end
