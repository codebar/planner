RSpec.shared_examples InvitationConcerns do |invitation_type|
  let(:invitation_constant) { invitation_type.to_s.camelize.constantize }
  let(:invitation) { Fabricate(invitation_type) }
  it 'has a token set on creation' do
    expect(invitation.token).to_not be(nil)
  end

  context '#scopes' do
    context '#accepted' do
      it 'ignores when attending nil' do
        Fabricate(invitation_type, attending: nil)

        expect(invitation_constant.accepted).to eq []
      end

      it 'ignores when attending false' do
        Fabricate(invitation_type, attending: false)

        expect(invitation_constant.accepted).to eq []
      end

      it 'selects when attending true' do
        invitation = Fabricate(invitation_type, attending: true)

        expect(invitation_constant.accepted).to include(invitation)
      end
    end

    context '#not_accepted' do
      it 'selects when attended nil' do
        Fabricate(invitation_type, attending: nil)

        expect(invitation_constant.not_accepted).to include(invitation)
      end

      it 'selects when attended false' do
        Fabricate(invitation_type, attending: false)

        expect(invitation_constant.not_accepted).to include(invitation)
      end

      it 'ignores when attended true' do
        invitation = Fabricate(invitation_type, attending: true)

        expect(invitation_constant.not_accepted).to eq []
      end
    end
  end
end
