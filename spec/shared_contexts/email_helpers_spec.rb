require 'rails_helper'

# Canary for EmailHelpers — same pattern as the 'with forgery protection
# enforced' canary. It delivers a real invitation email so a change to the
# mailer's part structure or to the test delivery path fails here instead of
# silently weakening every email assertion that uses the helper.
RSpec.describe EmailHelpers do
  let(:member) { Fabricate(:member) }
  let(:workshop) { Fabricate(:workshop) }
  let(:invitation) { Fabricate(:workshop_invitation, workshop:, member:) }

  it 'delivered_emails_to filters delivered mail by recipient' do
    WorkshopInvitationMailer.attending(workshop, member, invitation, false).deliver_now

    expect(delivered_emails_to(member)).not_to be_empty
    expect(delivered_emails_to('nobody@example.com')).to be_empty
  end

  it 'email_html reads the waiting-list html copy from the nested part' do
    WorkshopInvitationMailer.attending(workshop, member, invitation, true).deliver_now

    expect(email_html(delivered_emails_to(member).last))
      .to include('A spot became available and your attendance has now been confirmed!')
  end
end
