require 'rails_helper'

RSpec.describe Admin::Chapters::OrganisersController do
  let(:admin) { Fabricate(:chapter_organiser) }
  let(:chapter) { Fabricate(:chapter) }
  let(:member) { Fabricate(:member) }

  before do
    login_as_admin(admin)
  end

  describe 'POST #create' do
    it 'records organiser_role.granted' do
      post :create, params: {
        chapter_id: chapter.id, organiser: { organiser: member.id }
      }

      expect(PublicActivity::Activity.exists?(owner: admin, key: 'organiser_role.granted',
                                              recipient: member)).to be(true)
    end
  end

  describe 'DELETE #destroy' do
    before { member.add_role(:organiser, chapter) }

    it 'records organiser_role.revoked' do
      delete :destroy, params: { chapter_id: chapter.id, id: member.id }

      expect(PublicActivity::Activity.exists?(owner: admin, key: 'organiser_role.revoked',
                                              recipient: member)).to be(true)
    end
  end
end
