RSpec.describe MeetingInvitationMailer do
  let(:meeting) { Fabricate(:meeting) }
  let(:member) { Fabricate(:member) }
  let(:invitation) { Fabricate(:meeting_invitation, meeting: meeting, member: member) }

  context 'when the member has an invalid email' do
    let(:bad_member) { Fabricate(:member) }
    let(:bad_invitation) { Fabricate(:meeting_invitation, meeting: meeting, member: bad_member) }

    before { allow(bad_member).to receive(:email).and_return('invalid-email') }

    it '#invite skips delivery without crashing' do
      expect do
        described_class.invite(meeting, bad_member, bad_invitation).deliver_now
      end.not_to raise_error
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it '#attending skips delivery without crashing' do
      expect do
        described_class.attending(meeting, bad_member).deliver_now
      end.not_to raise_error
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it '#approve_from_waitlist skips delivery without crashing' do
      expect do
        described_class.approve_from_waitlist(meeting, bad_member).deliver_now
      end.not_to raise_error
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it '#attendance_reminder skips delivery without crashing' do
      expect do
        described_class.attendance_reminder(meeting, bad_member).deliver_now
      end.not_to raise_error
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  describe '#invite' do
    let(:mail) { described_class.invite(meeting, member, invitation).deliver_now }

    it 'renders the headers' do
      expect(mail.subject).to eq("You are invited to codebar\'s #{meeting.name} on #{humanize_date(meeting.date_and_time)}")
      expect(mail.to).to eq([member.email])
      expect(mail.from).to eq(['meetings@codebar.io'])
      expect(mail.cc).to eq([])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('We\'re back for another instalment of codebar Monthlies')
      expect(mail.body.encoded).to match('hello@codebar.io')
    end
  end

  describe '#attending' do
    let(:mail) { described_class.attending(meeting, member).deliver_now }

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
    let(:mail) { described_class.approve_from_waitlist(meeting, member).deliver_now }

    it 'renders the headers' do
      expect(mail.subject).to eq("A spot has opened up for #{meeting.name} on #{humanize_date(meeting.date_and_time)}")
      expect(mail.to).to eq([member.email])
      expect(mail.from).to eq(['meetings@codebar.io'])
      expect(mail.cc).to eq([])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('A spot has opened up for the next codebar Monthly')
      expect(mail.body.encoded).to match('hello@codebar.io')
    end
  end

  describe '#attendance_reminder' do
    let(:mail) { described_class.attendance_reminder(meeting, member).deliver_now }

    it 'renders the headers' do
      expect(mail.subject).to eq("Reminder: You have a spot for #{meeting.name} on #{humanize_date(meeting.date_and_time)}")
      expect(mail.to).to eq([member.email])
      expect(mail.from).to eq(['meetings@codebar.io'])
      expect(mail.cc).to eq([])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('codebar Monthly Attendance Reminder')
      expect(mail.body.encoded).to match('hello@codebar.io')
    end
  end
end
