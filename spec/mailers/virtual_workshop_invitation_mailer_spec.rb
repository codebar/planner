RSpec.describe VirtualWorkshopInvitationMailer do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:workshop) { Fabricate(:workshop) }
  let(:member) { Fabricate(:member) }
  let(:invitation) { Fabricate(:workshop_invitation, workshop: workshop, member: member) }

  context 'when the member has an invalid email' do
    let(:bad_member) { Fabricate(:member) }
    let(:bad_invitation) { Fabricate(:workshop_invitation, workshop: workshop, member: bad_member) }

    before { allow(bad_member).to receive(:email).and_return('invalid-email') }

    it '#attending skips delivery without crashing' do
      expect {
        VirtualWorkshopInvitationMailer.attending(workshop, bad_member, bad_invitation).deliver_now
      }.not_to raise_error
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it '#attending_reminder skips delivery without crashing' do
      expect {
        VirtualWorkshopInvitationMailer.attending_reminder(workshop, bad_member, bad_invitation).deliver_now
      }.not_to raise_error
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it '#invite_coach skips delivery without crashing' do
      expect {
        VirtualWorkshopInvitationMailer.invite_coach(workshop, bad_member, bad_invitation).deliver_now
      }.not_to raise_error
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it '#invite_student skips delivery without crashing' do
      expect {
        VirtualWorkshopInvitationMailer.invite_student(workshop, bad_member, bad_invitation).deliver_now
      }.not_to raise_error
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it '#waiting_list_reminder skips delivery without crashing' do
      expect {
        VirtualWorkshopInvitationMailer.waiting_list_reminder(workshop, bad_member, bad_invitation).deliver_now
      }.not_to raise_error
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  it '#attending' do
    email_subject = "Attendance Confirmation: Virtual workshop for #{workshop.chapter.name} " \
                    "🌐 #{humanize_date(workshop.date_and_time)}"

    VirtualWorkshopInvitationMailer.attending(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(workshop.chapter.email)
    expect(email.body.encoded).to match('How to join')
    expect(email.body.encoded).to match('Sign up to the codebar Slack')
    expect(email.body.encoded).to match('Accept the invitation')
  end

  it '#attending_reminder' do
    email_subject = "Virtual Workshop Reminder #{humanize_date(workshop.date_and_time, with_time: true)}"

    VirtualWorkshopInvitationMailer.attending_reminder(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(workshop.chapter.email)
    expect(email.body.encoded).to match('How to join')
    expect(email.body.encoded).to match('Sign up to the codebar Slack')
    expect(email.body.encoded).to match('Accept the invitation')
  end

  it '#attending includes the workshop description' do
    description = "This is a test workshop description."
    workshop = Fabricate(:workshop, description: description)
    invitation = Fabricate(:workshop_invitation, workshop: workshop, member: member)

    WorkshopInvitationMailer.attending(workshop, member, invitation).deliver_now

    expect(email.body.encoded).to include(description)
  end

  it '#invite_coach' do
    email_subject = "Virtual Workshop Coach Invitation #{humanize_date(workshop.date_and_time, with_time: true)}"

    VirtualWorkshopInvitationMailer.invite_coach(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(workshop.chapter.email)
  end

  it '#invite_student' do
    email_subject = "Virtual Workshop Invitation #{humanize_date(workshop.date_and_time, with_time: true)}"

    VirtualWorkshopInvitationMailer.invite_student(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.body.encoded).to match(workshop.chapter.email)
  end

  it '#waitlist_reminder' do
    email_subject = "Reminder: you're on the codebar waiting list " \
                    "(#{humanize_date(workshop.date_and_time, with_time: true)})"

    VirtualWorkshopInvitationMailer.waiting_list_reminder(workshop, member, invitation).deliver_now

    expect(email.subject).to eq(email_subject)
    expect(email.from).to eq([workshop.chapter.email])
    expect(email.body.encoded).to match("the virtual workshop on #{humanize_date(workshop.date_and_time, with_time: true)}")
    expect(email.body.encoded).to match(workshop.chapter.email)
  end
end
