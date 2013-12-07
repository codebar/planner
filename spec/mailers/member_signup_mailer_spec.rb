require "spec_helper"

describe MemberSignupMailer do
  let(:member) do
    double(
      Member,
      email: 'test@test.com'
    )
  end

  describe "#welcome_email" do
    subject { described_class.welcome_email(member).deliver }

    it "delivers the welome email" do
      expect(subject.to).to eq(['test@test.com'])
    end
  end
end
