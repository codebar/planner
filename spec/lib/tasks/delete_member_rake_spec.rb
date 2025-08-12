RSpec.describe 'rake member:delete', type: :task do
  let!(:member) { Fabricate.create(:member) }
  before do
    allow($stdout).to receive(:puts)
  end

  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  it 'when no email is provided' do
    regexed_msg = Regexp.quote("You have to provide an email address. Usage: rake member:delete'[email@address.com]'")
    expect { task.invoke }.to output(/#{regexed_msg}\s*/).to_stderr
      .and raise_error(SystemExit)
  end

  it 'anonymises member information' do
    invitations = Fabricate.times(2, :workshop_invitation, member: member)
    tokens = invitations.map(&:token)

    subscriptions = Fabricate.times(1, :subscription, member: member)

    allow($stdin).to receive(:getch)

    task.execute(email: member.email)

    member.reload

    expect(member.name).to eq('Deleted')
    expect(member.surname).to eq('User')
    expect(member.pronouns).to be_nil
    expect(member.about_you).to be_nil
    expect(member.twitter).to be_nil
    expect(member.mobile).to be_nil

    expect(member.subscriptions).to be_empty
    expect(member.auth_services).to be_empty

    invitations.each do |invitation|
      expect(tokens).not_to include(invitation.reload.token)
    end
  end
end
