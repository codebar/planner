require "spec_helper"

describe MemberSignupMailer do

  let(:email) { ActionMailer::Base.deliveries.last }

  let(:member) do
    double(
      Member,
      email: 'test@test.com'
    )
  end

  it "#welcome_email" do
    MemberSignupMailer.welcome_email(member).deliver

    expect(email.to).to eq(['test@test.com'])
  end
end
