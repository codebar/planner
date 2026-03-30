RSpec.describe Admin::WorkshopInvitationLogsController, type: :controller do
  let(:workshop) { Fabricate(:workshop) }
  let(:admin) { Fabricate(:member).tap { |m| m.add_role(:admin) } }
  let(:regular_member) { Fabricate(:member) }

  before { login_as_admin(admin) }

  describe 'GET #index' do
    it 'renders the index page' do
      get :index, params: { workshop_id: workshop.id }

      expect(response).to have_http_status(:success)
    end

    it 'denies access for regular members' do
      other_chapter = Fabricate(:chapter)
      login_as_organiser(regular_member, other_chapter)

      get :index, params: { workshop_id: workshop.id }

      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'GET #show' do
    let(:log) { Fabricate(:invitation_log, loggable: workshop) }

    it 'renders the show page' do
      get :show, params: { workshop_id: workshop.id, id: log.id }

      expect(response).to have_http_status(:success)
    end

    it 'denies access for regular members' do
      other_chapter = Fabricate(:chapter)
      login_as_organiser(regular_member, other_chapter)

      get :show, params: { workshop_id: workshop.id, id: log.id }

      expect(response).to have_http_status(:redirect)
    end
  end
end
