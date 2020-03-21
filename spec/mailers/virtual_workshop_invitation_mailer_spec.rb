require 'spec_helper'

RSpec.describe VirtualWorkshopInvitationMailer, type: :mailer do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:workshop) { Fabricate(:workshop) }
  let(:member) { Fabricate(:member) }
  let(:invitation) { Fabricate(:workshop_invitation, workshop: workshop, member: member) }

  it '#attending' do
    email_subject = "Attendance Confirmation: Virtual workshop for #{workshop.chapter.name} " \
                    "- #{I18n.l(workshop.date_and_time, format: :_humanize_date_with_time)}"

    VirtualWorkshopInvitationMailer.attending(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(workshop.chapter.email)
    expect(email.body.encoded).to match('How to join the virtual workshop')
  end

  it '#attending_reminder' do
    email_subject = "Virtual Workshop Reminder #{I18n.l(workshop.date_and_time, format: :_humanize_date_with_time)}"

    VirtualWorkshopInvitationMailer.attending_reminder(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(workshop.chapter.email)
    expect(email.body.encoded).to match('How to join the virtual workshop')
  end

  it '#invite_coach' do
    email_subject = "Virtual Workshop Coach Invitation " \
                    "#{I18n.l(workshop.date_and_time, format: :_humanize_date_with_time)}"

    VirtualWorkshopInvitationMailer.invite_coach(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(workshop.chapter.email)
  end

  it '#invite_student' do
    email_subject = "Virtual Workshop Invitation #{I18n.l(workshop.date_and_time, format: :_humanize_date_with_time)}"

    VirtualWorkshopInvitationMailer.invite_student(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(workshop.chapter.email)
  end

  it '#waitlist_reminder' do
    email_subject = "Reminder: you're on the codebar waiting list " \
                    "(#{I18n.l(workshop.date_and_time, format: :_humanize_date_with_time)})"

    VirtualWorkshopInvitationMailer.waiting_list_reminder(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.from).to eq([workshop.chapter.email])
    expect(email.body.encoded)
      .to match("the virtual workshop on #{I18n.l(workshop.date_and_time, format: :_humanize_date_with_time)}")
    expect(email.body.encoded).to match(workshop.chapter.email)
  end
end
