RSpec.shared_examples InvitationConcerns do |invitation_type, event_type|
  let(:invitation_constant) { invitation_type.to_s.camelize.constantize }
  let(:invitation) { Fabricate(invitation_type) }

  it 'has a token set on creation' do
    expect(invitation.token).to_not be(nil)
  end

  context '#scopes' do
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

    let(:past_event) { Fabricate(event_type, date_and_time: 2.days.ago) }
    let(:future_rsvp) { Fabricate(invitation_type, attending: true) }
    let(:past_rsvp) { Fabricate(invitation_type, attending: true, event_type => past_event) }
    let(:past_invitation) { Fabricate(invitation_type, event_type => past_event) }

    before(:each, data: true) do
      future_rsvp
      past_rsvp
      past_invitation
    end

    describe '#accepted', data: true do
      it 'returns a list of all rsvps' do
        expect(invitation_constant.joins(event_type).accepted).to contain_exactly(future_rsvp, past_rsvp)
      end
    end

    describe '#upcoming_rsvps', data: true do
      it 'returns a list of all upcoming rsvps' do
        expect(invitation_constant.joins(event_type).upcoming_rsvps).to contain_exactly(future_rsvp)
      end
    end

    describe '#taken_place', data: true do
      it 'returns a list of all invitations for events that have already taken place' do
        expect(invitation_constant.joins(event_type).taken_place).to contain_exactly(past_rsvp, past_invitation)
      end
    end
  end
end
