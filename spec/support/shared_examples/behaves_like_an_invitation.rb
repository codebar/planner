RSpec.shared_examples InvitationConcerns do |invitation_type, event_type|
  let(:invitation_constant) { invitation_type.to_s.camelize.constantize }
  let(:invitation) { Fabricate(invitation_type) }

  it 'has a token set on creation' do
    expect(invitation.token).not_to be_nil
  end

  describe '#scopes' do
    describe '#not_accepted' do
      it 'selects when attended nil' do
        Fabricate(invitation_type, attending: nil)

        expect(invitation_constant.not_accepted).to include(invitation)
      end

      it 'selects when attended false' do
        Fabricate(invitation_type, attending: false)

        expect(invitation_constant.not_accepted).to include(invitation)
      end

      it 'ignores when attended true' do
        Fabricate(invitation_type, attending: true)

        expect(invitation_constant.not_accepted).to eq []
      end
    end

    describe '#accepted', :data do
      it 'returns a list of all rsvps' do
        travel_to(Time.current) do
          past_event = Fabricate(event_type, date_and_time: 2.days.ago)
          future_rsvp = Fabricate(invitation_type, attending: true)
          past_rsvp = Fabricate(invitation_type, attending: true, event_type => past_event)

          expect(invitation_constant.joins(event_type).accepted).to contain_exactly(future_rsvp, past_rsvp)
        end
      end
    end

    describe '#upcoming_rsvps', :data do
      it 'returns a list of all upcoming rsvps' do
        travel_to(Time.current) do
          past_event = Fabricate(event_type, date_and_time: 2.days.ago)
          future_rsvp = Fabricate(invitation_type, attending: true)
          Fabricate(invitation_type, attending: true, event_type => past_event)

          expect(invitation_constant.joins(event_type).upcoming_rsvps).to contain_exactly(future_rsvp)
        end
      end
    end

    describe '#taken_place', :data do
      it 'returns a list of all invitations for events that have already taken place' do
        travel_to(Time.current) do
          past_event = Fabricate(event_type, date_and_time: 2.days.ago)
          Fabricate(invitation_type, attending: true)
          past_rsvp = Fabricate(invitation_type, attending: true, event_type => past_event)
          past_invitation = Fabricate(invitation_type, event_type => past_event)

          expect(invitation_constant.joins(event_type).taken_place).to contain_exactly(past_rsvp, past_invitation)
        end
      end
    end
  end
end
