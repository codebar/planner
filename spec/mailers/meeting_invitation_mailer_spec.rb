require 'spec_helper'

RSpec.describe MeetingInvitationMailer, type: :mailer do
  let(:meeting) { Fabricate(:meeting) }
  let(:member) { Fabricate(:member) }

  describe '#invite' do
    let(:mail) { MeetingInvitationMailer.invite(meeting, member).deliver_now }

    it 'renders the headers' do
      expect(mail.subject).to eq("You are invited to codebar\'s #{meeting.name} on #{humanize_date(meeting.date_and_time)}")
      expect(mail.to).to eq([member.email])
      expect(mail.from).to eq(['meetings@codebar.io'])
      expect(mail.cc).to eq([])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('We\'re back for another installment of codebar Monthlies')
      expect(mail.body.encoded).to match('hello@codebar.io')
    end
  end

  describe '#attending' do
    let(:mail) { MeetingInvitationMailer.attending(meeting, member).deliver_now }

    it 'renders the headers' do
      expect(mail.subject).to eq("See you at #{meeting.name} on #{humanize_date(meeting.date_and_time)}")
      expect(mail.to).to eq([member.email])
      expect(mail.from).to eq(['meetings@codebar.io'])
      expect(mail.cc).to eq([])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('You\'re confirmed for the next codebar Monthly')
      expect(mail.body.encoded).to match('hello@codebar.io')
    end
  end

  describe '#approve_from_waitlist' do
    let(:mail) { MeetingInvitationMailer.approve_from_waitlist(meeting, member).deliver_now }

    it 'renders the headers' do
      expect(mail.subject).to eq("A spot opened up for #{meeting.name} on #{humanize_date(meeting.date_and_time)}")
      expect(mail.to).to eq([member.email])
      expect(mail.from).to eq(['meetings@codebar.io'])
      expect(mail.cc).to eq([])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('A spot opened up for the next codebar Monthly')
      expect(mail.body.encoded).to match('hello@codebar.io')
    end
  end

  describe '#attendance_reminder' do
    let(:mail) { MeetingInvitationMailer.attendance_reminder(meeting, member).deliver_now }

    it 'renders the headers' do
      expect(mail.subject).to eq("Reminder: You have a spot for #{meeting.name} on #{humanize_date(meeting.date_and_time)}")
      expect(mail.to).to eq([member.email])
      expect(mail.from).to eq(['meetings@codebar.io'])
      expect(mail.cc).to eq([])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('This is a quick email to remind you that you have signed up for tomorrow\'s codebar Monthly')
      expect(mail.body.encoded).to match('hello@codebar.io')
    end
  end
end
