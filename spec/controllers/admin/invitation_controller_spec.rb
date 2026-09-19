require 'rails_helper'

RSpec.describe Admin::InvitationController do
  describe 'POST #verify' do
    let(:invitation) { Fabricate(:invitation, attending: false, verified: nil) }
    let(:admin) { Fabricate(:chapter_organiser) }

    before do
      admin.add_role(:admin)
      login admin
      request.env['HTTP_REFERER'] = '/admin/member/3'
    end

    it 'records invitation.verified' do
      post :verify, params: { event_id: invitation.event.id, invitation_id: invitation.token }

      expect(PublicActivity::Activity.exists?(owner: admin, key: 'invitation.verified',
                                              recipient: invitation.member)).to be(true)
    end
  end
end
