require "spec_helper"

describe SessionInvitationMailer do

  let(:email) { ActionMailer::Base.deliveries.last }
  let(:session) { Fabricate(:sessions, title: "HTML & CSS") }
  let(:member) { Fabricate(:member) }
  let(:invitation) { Fabricate(:session_invitation, sessions: session, member: member) }

  context "#invite_student" do
    it "Emails students an invitation" do
      email_subject = "Workshop Invitation #{humanize_date_with_time(session.date_and_time, session.time)}"
      SessionInvitationMailer.invite_student(session, member, invitation).deliver

      expect(email.subject).to eq(email_subject)
    end

    it "Includes the invitation note in the email" do
      content = Faker::Lorem.paragraph
      session.update_attribute(:invite_note, content)
      SessionInvitationMailer.invite_student(session, member, invitation).deliver

      expect(email.body.encoded).to include(content)
    end
  end

  context "#invite_coach" do
    it "Emails students an invitation" do
      email_subject = "Workshop Coach Invitation #{humanize_date_with_time(session.date_and_time, session.time)}"
      SessionInvitationMailer.invite_coach(session, member, invitation).deliver

      expect(email.subject).to eq(email_subject)
    end

    it "Includes the invitation note in the email" do
      content = Faker::Lorem.paragraph
      session.update_attribute(:invite_note, content)
      SessionInvitationMailer.invite_coach(session, member, invitation).deliver

      expect(email.body.encoded).to include(content)
    end
  end

  context "#attending" do
    it "Includes the invitation note in the email" do
      content = Faker::Lorem.paragraph
      session.update_attribute(:invite_note, content)
      SessionInvitationMailer.attending(session, member, invitation).deliver

      expect(email.body.encoded).to include(content)
    end
  end

  context "#attending_reminder" do
    it "Emails a reminder to attending members" do
      email_subject = "Workshop Reminder #{humanize_date_with_time(session.date_and_time, session.time)}"
      SessionInvitationMailer.attending_reminder(session, member, invitation).deliver

      expect(email.subject).to eq(email_subject)
    end

    it "Includes the invitation note in the email" do
      content = Faker::Lorem.paragraph
      session.update_attribute(:invite_note, content)
      SessionInvitationMailer.attending_reminder(session, member, invitation).deliver

      expect(email.body.encoded).to include(content)
    end
  end

  context "#waiting_list_reminder" do
    it "Includes an invitation note in the email" do
      content = Faker::Lorem.paragraph
      session.update_attribute(:invite_note, content)
      SessionInvitationMailer.waiting_list_reminder(session, member, invitation).deliver

      expect(email.body.encoded).to include(content)
    end
  end
end
