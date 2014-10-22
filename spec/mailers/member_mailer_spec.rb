require "spec_helper"

RSpec.describe MemberMailer, :type => :mailer do
  describe "welcome_student" do
    let(:member) { Fabricate(:member) }
    let(:mail) { MemberMailer.welcome_student(member) }

    it "renders the headers" do
      expect(mail.subject).to eq("Welcome to Codebar!")
      expect(mail.to).to eq([member.email])
      expect(mail.from).to eq(["meetings@codebar.io"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Places are limited")
    end
  end

  describe "welcome_coach" do
    let(:member) { Fabricate(:member) }
    let(:mail) { MemberMailer.welcome_coach(member) }

    it "renders the headers" do
      expect(mail.subject).to eq("Welcome to Codebar!")
      expect(mail.to).to eq([member.email])
      expect(mail.from).to eq(["meetings@codebar.io"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("depends on coaches attending")
    end
  end

  describe "welcome" do
    it "sends the coach welcome email to coaches" do
      member = Fabricate(:coach)
      expect_any_instance_of(MemberMailer).to receive(:welcome_coach)
      expect_any_instance_of(MemberMailer).not_to receive(:welcome_student)
      MemberMailer.welcome member
    end

    it "sends the student welcome email to students" do
      member = Fabricate(:student)
      expect_any_instance_of(MemberMailer).not_to receive(:welcome_coach)
      expect_any_instance_of(MemberMailer).to receive(:welcome_student)
      MemberMailer.welcome member
    end

    it "actually sends a coach email" do
      member = Fabricate(:coach)
      expect {
        MemberMailer.welcome member
      }.to change {ActionMailer::Base.deliveries.count}.by 1
    end

    it "actually sends a student email" do
      member = Fabricate(:student)
      expect {
        MemberMailer.welcome member
      }.to change {ActionMailer::Base.deliveries.count}.by 1
    end
  end

end
