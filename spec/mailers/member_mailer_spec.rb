require 'spec_helper'

RSpec.describe MemberMailer, type: :mailer do
  let(:member) { Fabricate(:member) }

  describe 'welcome_student' do
    let(:mail) { MemberMailer.welcome_student(member).deliver_now }

    it 'renders the headers' do
      expect(mail.subject).to eq('How codebar works')
      expect(mail.to).to eq([member.email])
      expect(mail.from).to eq(['hello@codebar.io'])
      expect(mail.cc).to eq([])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Places are limited')
    end
  end

  describe 'welcome_coach' do
    let(:mail) { MemberMailer.welcome_coach(member).deliver_now }

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
    let(:mail) { MemberMailer.eligibility_check(member).deliver_now }

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
    let(:mail) { MemberMailer.attendance_warning(member).deliver_now }

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
    let(:mail) { MemberMailer.ban(member, ban).deliver_now }

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

      expect_any_instance_of(MemberMailer).to receive(:welcome_coach)
      expect_any_instance_of(MemberMailer).not_to receive(:welcome_student)
      MemberMailer.welcome(member).deliver_now
    end

    it 'sends the student welcome email to students' do
      member = Fabricate(:student)
      expect_any_instance_of(MemberMailer).not_to receive(:welcome_coach)
      expect_any_instance_of(MemberMailer).to receive(:welcome_student)
      MemberMailer.welcome(member).deliver_now
    end

    it 'sends a ban email to a member' do
      member = Fabricate(:member)
      ban = Fabricate(:ban)
      expect_any_instance_of(MemberMailer).to receive(:ban).with(member, ban)

      MemberMailer.ban(member, ban).deliver_now
    end


    it 'actually sends a coach email' do
      member = Fabricate(:coach)
      expect {
        MemberMailer.welcome(member).deliver_now
      }.to change { ActionMailer::Base.deliveries.count }.by 1
    end

    it 'actually sends a student email' do
      member = Fabricate(:student)
      expect {
        MemberMailer.welcome(member).deliver_now
      }.to change { ActionMailer::Base.deliveries.count }.by 1
    end
  end
end
