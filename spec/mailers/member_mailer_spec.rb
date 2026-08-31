RSpec.describe MemberMailer do
  let(:member) { Fabricate(:member) }

  context 'when the member has an invalid email' do
    let(:bad_member) { Fabricate(:member) }

    before { allow(bad_member).to receive(:email).and_return('invalid-email') }

    it '#welcome_student skips delivery without crashing' do
      expect do
        described_class.welcome_student(bad_member).deliver_now
      end.not_to raise_error
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it '#welcome_coach skips delivery without crashing' do
      expect do
        described_class.welcome_coach(bad_member).deliver_now
      end.not_to raise_error
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it '#eligibility_check skips delivery without crashing' do
      expect do
        described_class.eligibility_check(bad_member).deliver_now
      end.not_to raise_error
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it '#attendance_warning skips delivery without crashing' do
      expect do
        described_class.attendance_warning(bad_member).deliver_now
      end.not_to raise_error
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it '#ban skips delivery without crashing' do
      ban = Fabricate(:ban, member: bad_member)
      expect do
        described_class.ban(bad_member, ban).deliver_now
      end.not_to raise_error
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it '#chaser skips delivery without crashing' do
      expect do
        described_class.with(member: bad_member).chaser.deliver_now
      end.not_to raise_error
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  describe 'welcome_student' do
    let(:mail) { described_class.welcome_student(member).deliver_now }

    it 'renders the headers' do
      expect(mail.subject).to eq('How codebar works')
      expect(mail.to).to eq([member.email])
      expect(mail.from).to eq(['hello@codebar.io'])
      expect(mail.cc).to eq([])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Spots are limited')
    end
  end

  describe 'welcome_coach' do
    let(:mail) { described_class.welcome_coach(member).deliver_now }

    it 'renders the headers' do
      expect(mail.subject).to eq('How codebar works')
      expect(mail.to).to eq([member.email])
      expect(mail.from).to eq(['hello@codebar.io'])
      expect(mail.cc).to eq([])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('depends on coaches attending')
    end
  end

  describe 'eligibility check' do
    let(:mail) { described_class.eligibility_check(member).deliver_now }

    it 'renders the headers' do
      expect(mail.subject).to eq('Eligibility confirmation')
      expect(mail.to).to eq([member.email])
      expect(mail.from).to eq(['hello@codebar.io'])
      expect(mail.cc).to eq(['hello@codebar.io'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('we hope you understand why we need to ask')
    end
  end

  describe 'attendance warning' do
    let(:mail) { described_class.attendance_warning(member).deliver_now }

    it 'renders the headers' do
      expect(mail.subject).to eq('Attendance warning')
      expect(mail.to).to eq([member.email])
      expect(mail.from).to eq(['hello@codebar.io'])
      expect(mail.cc).to eq(['hello@codebar.io'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('you have missed more than 2 workshops')
    end
  end

  describe 'ban email' do
    let(:ban) { Fabricate(:ban, reason: 'Attendance violation') }
    let(:mail) { described_class.ban(member, ban).deliver_now }

    it 'renders the headers' do
      expect(mail.subject).to eq('Attendance violation')
      expect(mail.to).to eq([member.email])
      expect(mail.from).to eq(['hello@codebar.io'])
      expect(mail.cc).to eq(['hello@codebar.io'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('your account has been suspended')
    end
  end

  describe 'welcome' do
    it 'sends the coach welcome email to coaches' do
      member = Fabricate(:coach)

      mail = described_class.welcome(member).deliver_now

      expect(mail.body.encoded).to match('depends on coaches attending')
    end

    it 'sends the student welcome email to students' do
      member = Fabricate(:student)

      mail = described_class.welcome(member).deliver_now

      expect(mail.body.encoded).to match('Spots are limited')
    end

    it 'sends a ban email to a member' do
      member = Fabricate(:member)
      ban = Fabricate(:ban)

      mail = described_class.ban(member, ban).deliver_now

      expect(mail.to).to eq([member.email])
      expect(mail.body.encoded).to match('your account has been suspended')
    end

    it 'actually sends a coach email' do
      member = Fabricate(:coach)
      expect do
        described_class.welcome(member).deliver_now
      end.to change { ActionMailer::Base.deliveries.count }.by 1
    end

    it 'actually sends a student email' do
      member = Fabricate(:student)
      expect do
        described_class.welcome(member).deliver_now
      end.to change { ActionMailer::Base.deliveries.count }.by 1
    end
  end

  describe '#chaser' do
    it 'logs the sent email' do
      expect do
        described_class
          .with(member: member)
          .chaser
          .deliver_now
      end.to change(MemberEmailDelivery, :count).by(1)

      log = MemberEmailDelivery.last!

      expect(log.member).to eq(member)
      expect(log.email_type).to eq('chaser')
      expect(log.subject).to eq('It’s been a while, how are you doing? ♥️')
      expect(log.to).to eq([member.email])
      # premailer-rails converts the message to multipart/alternative during
      # delivery, so the logged body must come from the html part
      expect(log.body).to be_present
      expect(log.body).to include('codebar workshop')
    end

    it 'logs one row per member even if the delivery is performed twice' do
      expect do
        described_class.with(member: member).chaser.deliver_now
        described_class.with(member:).chaser.deliver_now
      end.to change(MemberEmailDelivery, :count).by(1)
    end
  end
end
