require 'spec_helper'

RSpec.describe VirtualWorkshopInvitationMailer, type: :mailer do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:workshop) { Fabricate(:workshop) }
  let(:member) { Fabricate(:member) }
  let(:invitation) { Fabricate(:workshop_invitation, workshop: workshop, member: member) }

  it '#attending' do
    email_subject = "Attendance Confirmation: Virtual workshop for #{workshop.chapter.name} " \
                    "- #{humanize_date(workshop.date_and_time)}"

    VirtualWorkshopInvitationMailer.attending(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(workshop.chapter.email)
    expect(email.body.encoded).to match('How to join')
    expect(email.body.encoded).to match('Sign up to the codebar Slack')
    expect(email.body.encoded).to match('Accept the invitation')
  end

  it '#attending_reminder' do
    email_subject = "Virtual Workshop Reminder #{humanize_date(workshop.date_and_time, with_time: true)}"

    VirtualWorkshopInvitationMailer.attending_reminder(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(workshop.chapter.email)
    expect(email.body.encoded).to match('How to join')
    expect(email.body.encoded).to match('Sign up to the codebar Slack')
    expect(email.body.encoded).to match('Accept the invitation')
  end

  it '#invite_coach' do
    email_subject = "Virtual Workshop Coach Invitation #{humanize_date(workshop.date_and_time, with_time: true)}"

    VirtualWorkshopInvitationMailer.invite_coach(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(workshop.chapter.email)
  end

  it '#invite_student' do
    email_subject = "Virtual Workshop Invitation #{humanize_date(workshop.date_and_time, with_time: true)}"

    VirtualWorkshopInvitationMailer.invite_student(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(workshop.chapter.email)
  end

  it '#waitlist_reminder' do
    email_subject = "Reminder: you're on the codebar waiting list " \
                    "(#{humanize_date(workshop.date_and_time, with_time: true)})"

    VirtualWorkshopInvitationMailer.waiting_list_reminder(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.from).to eq([workshop.chapter.email])
    expect(email.body.encoded).to match("the virtual workshop on #{humanize_date(workshop.date_and_time, with_time: true)}")
    expect(email.body.encoded).to match(workshop.chapter.email)
  end
end
