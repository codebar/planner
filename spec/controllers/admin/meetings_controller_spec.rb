RSpec.describe Admin::MeetingsController do
  let(:member) { Fabricate(:member) }
  let(:meeting) { Fabricate(:meeting) }

  before do
    member.add_role(:organiser, meeting)
    login(member)
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
      get :edit, params: { id: meeting.slug }

      expect(response.body).to include("value=\"#{meeting.date_and_time.strftime('%Y-%m-%d')}\"")
      expect(response.body).to include("value=\"#{meeting.time.strftime('%H:%M')}\"")
    end
  end
end
