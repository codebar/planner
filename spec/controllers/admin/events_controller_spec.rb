RSpec.describe Admin::EventsController, type: :controller do
  let(:admin) { Fabricate(:member) }
  let(:event) { Fabricate(:event, chapters: [chapter]) }
  let(:chapter) { Fabricate(:chapter) }

  before do
    admin.add_role(:organiser, event)
    login(admin)
  end

  describe 'POST #invite' do
    it 'passes current_user.id to send_event_emails' do
      manager = instance_spy(InvitationManager)
      allow(InvitationManager).to receive(:new).and_return(manager)

      post :invite, params: { event_id: event.slug }

      expect(manager).to have_received(:send_event_emails).with(event, chapter, admin.id)
    end

    it 'redirects to the event page' do
      post :invite, params: { event_id: event.slug }

      expect(response).to redirect_to(admin_event_path(event))
    end

    it 'sets a notice' do
      post :invite, params: { event_id: event.slug }

      expect(flash[:notice]).to eq('Invitations will be emailed out soon.')
    end
  end

  describe 'POST #invite with unauthorised user' do
    it 'redirects unauthorised users' do
      unauthorised = Fabricate(:member)
      login(unauthorised)

      post :invite, params: { event_id: event.slug }

      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq('You can\'t be here')
    end
  end

  describe 'GET #new' do
    render_views

    it 'renders with native date and time inputs' do
      get :new

      expect(response.body).to include('type="date"')
      expect(response.body).to include('type="time"')
    end
  end

  describe 'GET #edit' do
    render_views

    it 'pre-fills date and time values in ISO format' do
      get :edit, params: { id: event.slug }

      expect(response.body).to include("value=\"#{event.date_and_time.strftime('%Y-%m-%d')}\"")
      expect(response.body).to include("value=\"#{event.time.strftime('%H:%M')}\"")
    end
  end
end
