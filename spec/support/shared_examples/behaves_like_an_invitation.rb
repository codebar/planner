shared_examples InvitationConcerns do
  it "has a token set on creation" do

    invitation.token.should_not be nil
  end

  context "#scopes" do
    it "#accepted" do
      invitation.class.accepted.length.should eq 2
    end
  end
end
