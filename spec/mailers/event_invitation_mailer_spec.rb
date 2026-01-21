RSpec.describe EventInvitationMailer do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:event) { Fabricate(:event, date_and_time: Time.zone.local(2017, 11, 12, 10, 0), name: 'Test event') }
  let(:coach_event) { Fabricate(:event, date_and_time: Time.zone.local(2017, 11, 12, 10, 0), name: 'Test event', audience: 'Coaches') }
  let(:member) { Fabricate(:member) }
  let(:invitation) { Fabricate(:invitation, event: event, member: member) }

  it '#invite_student' do
    email_subject = "Invitation: #{event.name}"
    EventInvitationMailer.invite_student(event, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match('hello@codebar.io')
  end

  describe '#invite_coach' do
    it 'sends a generic invitation if the event has no audiencce' do
      email_subject = "Invitation: #{event.name}"
      EventInvitationMailer.invite_coach(event, member, invitation).deliver_now

      expect(email.subject).to eq(email_subject)
      expect(email.body.encoded).to match('hello@codebar.io')
    end

    it 'sends a coach invitation of the event is for coaches' do
      email_subject = "Coach Invitation: #{event.name}"
      EventInvitationMailer.invite_coach(coach_event, member, invitation).deliver_now

      expect(email.subject).to eq(email_subject)
      expect(email.body.encoded).to match('hello@codebar.io')
    end
  end

  it '#attending' do
    email_subject = "Your spot to #{event.name} has been confirmed."
    EventInvitationMailer.attending(event, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match('hello@codebar.io')
  end

  describe 'XSS protection' do
    let(:event_with_html) do
      Fabricate(:event,
        date_and_time: Time.zone.local(2017, 11, 12, 10, 0),
        name: 'Test event',
        description: '<script>alert("xss")</script><p>Safe content</p>')
    end
    let(:invitation_with_html) { Fabricate(:invitation, event: event_with_html, member: member) }

    it 'sanitizes description in invite_student email' do
      EventInvitationMailer.invite_student(event_with_html, member, invitation_with_html).deliver_now

      expect(email.body.encoded).not_to include('<script>')
      expect(email.body.encoded).to include('Safe content')
    end

    it 'sanitizes description in invite_coach email' do
      EventInvitationMailer.invite_coach(event_with_html, member, invitation_with_html).deliver_now

      expect(email.body.encoded).not_to include('<script>')
      expect(email.body.encoded).to include('Safe content')
    end
  end
end
