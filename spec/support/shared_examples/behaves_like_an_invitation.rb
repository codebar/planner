shared_examples InvitationConcerns do
  it 'has a token set on creation' do
    expect(invitation.token).to_not be(nil)
  end

  context '#scopes' do
    it '#accepted' do
      expect(invitation.class.accepted.length).to eq(2)
    end
  end
end
