require 'spec_helper'

RSpec.describe WorkshopInvitationMailer, type: :mailer do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:workshop) { Fabricate(:workshop, title: 'HTML & CSS') }
  let(:member) { Fabricate(:member) }
  let(:invitation) { Fabricate(:workshop_invitation, workshop: workshop, member: member) }
  let(:sponsor) { Fabricate(:sponsor) }

  it "#attending" do
    email_subject = "Attendance Confirmation for " \
                    "#{I18n.l(workshop.date_and_time, format: :humanize_date_with_time)}"

    WorkshopInvitationMailer.attending(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(workshop.chapter.email)
  end

  it '#attending_reminder' do
    email_subject = "Workshop Reminder #{I18n.l(workshop.date_and_time, format: :humanize_date_with_time)}"

    WorkshopInvitationMailer.attending_reminder(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(workshop.chapter.email)
  end

  it '#change_of_details' do
    title = 'Change of details'
    email_subject = "#{title}: #{workshop.title} by codebar - " \
                    "#{I18n.l(workshop.date_and_time, format: :humanize_date_with_time)}"

    WorkshopInvitationMailer.change_of_details(workshop, sponsor, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.from).to eq([workshop.chapter.email])
  end

  it '#invite_coach' do
    email_subject = "Workshop Coach Invitation " \
                    "#{I18n.l(workshop.date_and_time, format: :humanize_date_with_time)}"

    WorkshopInvitationMailer.invite_coach(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(workshop.chapter.email)
  end

  it '#invite_student' do
    email_subject = "Workshop Invitation #{I18n.l(workshop.date_and_time, format: :humanize_date_with_time)}"

    WorkshopInvitationMailer.invite_student(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(workshop.chapter.email)
  end

  it '#notify_waiting_list' do
    WorkshopInvitationMailer.notify_waiting_list(invitation).deliver_now

    expect(email.subject).to eq('A spot just became available')
    expect(email.from).to eq([workshop.chapter.email])
    expect(email.body.encoded).to match('A spot just opened up for the workshop')
  end

  it '#waitlist_reminder' do
    email_subject = "Reminder: you're on the codebar waiting list " \
                    "(#{I18n.l(workshop.date_and_time, format: :humanize_date_with_time)})"

    WorkshopInvitationMailer.waiting_list_reminder(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.from).to eq([workshop.chapter.email])
    expect(email.body.encoded).to match("the workshop on #{I18n.l(workshop.date_and_time, format: :humanize_date_with_time)}")
    expect(email.body.encoded).to match(workshop.chapter.email)
  end
end
