RSpec.describe Admin::WorkshopsController, type: :controller do
  let!(:workshop) { Fabricate(:workshop) }
  let(:admin) { Fabricate(:member) }

  before do
    login_as_organiser(admin, workshop.chapter)
  end

  def count_queries(&block)
    n = 0
    callback = ->(*) { n += 1 }
    ActiveSupport::Notifications.subscribed(callback, 'sql.active_record', &block)
    n
  end

  def assigns(symbol)
    controller.instance_variable_get("@#{symbol}")
  end

  describe 'GET #show' do
    it 'loads the workshop attendance page with attendees' do
      Fabricate(:workshop_invitation, workshop:, attending: true)
      get :show, params: { id: workshop.id }

      expect(response).to have_http_status(:success)
    end

    it 'loads the attendance page in a bounded number of queries, regardless of attendee count' do
      attendee = Fabricate(:member)
      4.times { Fabricate(:past_attending_workshop_invitation, member: attendee) }
      2.times { Fabricate(:attendance_warning, member: attendee) }
      Fabricate(:member_note, member: attendee, created_at: 1.day.ago)
      Fabricate(:workshop_invitation, workshop:, member: attendee, attending: true, role: 'Student')
      Fabricate(:workshop_invitation, workshop:, attending: true, role: 'Coach')

      # adds a second attendee to catch per-row scaling
      Fabricate(:workshop_invitation, workshop:, attending: true, role: 'Student')

      count = count_queries { get :show, params: { id: workshop.id } }

      expect(response).to have_http_status(:success)
      expect(count).to be < 50
    end

    context 'when rendering the page' do
      render_views

      it 'links to the RSVP members page instead of rendering an invitations select' do
        Fabricate(:workshop_invitation, workshop:, attending: nil)
        get :show, params: { id: workshop.id }

        expect(response.body).to include(admin_workshop_rsvp_path(workshop))
        expect(response.body).not_to include('chosen-select')
        expect(response.body).not_to include('outstanding invitations')
      end
    end
  end

  describe 'GET #rsvp' do
    render_views

    let(:member) { Fabricate(:member, name: 'Zoe', surname: 'Searchable') }
    let!(:matching) { Fabricate(:workshop_invitation, workshop:, member:, attending: nil) }

    before do
      Fabricate(:ban, member: Fabricate(:member, name: 'Bob', surname: 'Banned'))
      Fabricate(:workshop_invitation, workshop:, attending: true) # an already-attending member (counts toward eligible)
      Fabricate(:workshop_invitation, member:) # an invite for a DIFFERENT workshop
    end

    it 'is not accessible without organiser rights' do
      allow(controller).to receive(:manager?).and_return(false)
      get :rsvp, params: { workshop_id: workshop.id }

      expect(response).to redirect_to(root_path)
    end

    it 'assigns the eligible count and no invitations when no search term is given' do
      get :rsvp, params: { workshop_id: workshop.id }

      expect(assigns(:eligible_count)).to eq(2) # matching + other; banned is excluded from the count
      expect(assigns(:invitations)).to be_nil
      expect(response).to have_http_status(:success)
    end

    it 'returns only matching invited members for the workshop, excluding banned members' do
      get :rsvp, params: { workshop_id: workshop.id, q: 'Zoe' }

      expect(assigns(:invitations).map(&:id)).to eq([matching.id])
    end

    it 'excludes banned members from search results' do
      get :rsvp, params: { workshop_id: workshop.id, q: 'Banned' }

      expect(assigns(:invitations)).to be_empty
      expect(response.body).to include('No members found')
    end

    it 'filters by member name case-insensitively across first and surname' do
      get :rsvp, params: { workshop_id: workshop.id, q: 'SEARCHA' }

      expect(assigns(:invitations).map(&:id)).to eq([matching.id])
    end

    it 'eager loads member so rendering does not query per row' do
      3.times { Fabricate(:workshop_invitation, workshop:, member: Fabricate(:member, name: 'Eager', surname: 'Load'), attending: nil) }

      get :rsvp, params: { workshop_id: workshop.id, q: 'Eager' }

      expect(assigns(:invitations).all? { |i| i.association(:member).loaded? }).to be(true)
    end

    it 'paginates results at 20 per page and preserves the search term across pages' do
      21.times do |i|
        Fabricate(:workshop_invitation, workshop:, member: Fabricate(:member, name: "Page#{i}", surname: 'User'), attending: nil)
      end

      get :rsvp, params: { workshop_id: workshop.id, q: 'Page' }

      expect(assigns(:pagy).pages).to eq(2)
      expect(assigns(:invitations).size).to eq(20)
      expect(response.body).to include('page=2')

      get :rsvp, params: { workshop_id: workshop.id, q: 'Page', page: 2 }

      expect(assigns(:invitations).size).to eq(1)
      expect(assigns(:invitations).first.member.name).to start_with('Page')
    end

    it 'renders the not-attending badge and RSVP toggle for a declined member' do
      declined = Fabricate(:member, name: 'Declined', surname: 'Member')
      Fabricate(:workshop_invitation, workshop:, member: declined, attending: false)

      get :rsvp, params: { workshop_id: workshop.id, q: 'Declined' }

      expect(response.body).to include('Not attending')
      expect(response.body).to include('RSVP')
      expect(response.body).not_to include('Mark as not attending')
    end

    it 'renders the eligible count, search box, back link and toggle forms' do
      get :rsvp, params: { workshop_id: workshop.id, q: 'Zoe' }

      expect(response.body).to include('invited members')
      expect(response.body).to include('Search')
      expect(response.body).to include('Back to')
      # q: 'Zoe' only returns `matching` (attending: nil) -> its button says 'RSVP'
      expect(response.body).to include('RSVP')
      expect(response.body).not_to include('Mark as not attending')
    end

    it 'renders the not-attending toggle for an already-attending result' do
      attending_member = Fabricate(:member, name: 'Aaron', surname: 'Other')
      Fabricate(:workshop_invitation, workshop:, member: attending_member, attending: true)

      get :rsvp, params: { workshop_id: workshop.id, q: 'Aaron' }

      expect(response.body).to include('Mark as not attending')
    end
  end

  describe 'POST #create' do
    it 'permits rsvp_close_local_date and rsvp_close_local_time' do
      expect do
        post :create, params: { workshop: { rsvp_close_local_date: '01/12/2020', rsvp_close_local_time: '15:00', host: '' } }
      end.not_to raise_error
    end
  end

  describe 'DELETE #destroy' do
    context 'when workshop invitations have been sent' do
      before do
        Fabricate(:attending_workshop_invitation, workshop:)
      end

      context "when workshop deletion tried within specific time frame since it's creation" do
        it 'does not delete the workshop' do
          expect do
            delete :destroy, params: { id: workshop.id }
          end.not_to change(Workshop, :count)
        end

        it "displays workshop can't be deleted related flash message" do
          delete :destroy, params: { id: workshop.id }

          expect(flash[:notice]).to eq(I18n.t('admin.workshop.destroy.failure'))
        end
      end

      context "when workshop deletion tried outside specific time frame since it's creation" do
        it 'does not delete the workshop' do
          new_current_time = 1.day + Admin::WorkshopsController::
                                     WORKSHOP_DELETION_TIME_FRAME_SINCE_CREATION

          travel new_current_time do
            expect do
              delete :destroy, params: { id: workshop.id }
            end.not_to change(Workshop, :count)
          end
        end

        it "displays workshop can't be deleted related flash message" do
          new_current_time = 1.day + Admin::WorkshopsController::
                                     WORKSHOP_DELETION_TIME_FRAME_SINCE_CREATION

          travel new_current_time do
            delete :destroy, params: { id: workshop.id }
          end

          expect(flash[:notice]).to eq(I18n.t('admin.workshop.destroy.failure'))
        end
      end
    end

    context "when workshop invitations haven't been sent" do
      context "when workshop deletion tried within specific time frame since it's creation" do
        it 'successfully deletes the workshop' do
          expect do
            delete :destroy, params: { id: workshop.id }
          end.to change(Workshop, :count).by(-1)
        end

        it 'displays workshop deleted successfully related flash message' do
          delete :destroy, params: { id: workshop.id }

          expect(flash[:notice]).to eq(I18n.t('admin.workshop.destroy.success'))
        end
      end

      context "when workshop deletion tried outside specific time frame since it's creation" do
        it 'does not delete the workshop' do
          new_current_time = 1.day + Admin::WorkshopsController::
                                     WORKSHOP_DELETION_TIME_FRAME_SINCE_CREATION

          travel new_current_time do
            expect do
              delete :destroy, params: { id: workshop.id }
            end.not_to change(Workshop, :count)
          end
        end

        it "displays workshop can't be deleted related flash message" do
          new_current_time = 1.day + Admin::WorkshopsController::
                                     WORKSHOP_DELETION_TIME_FRAME_SINCE_CREATION

          travel new_current_time do
            delete :destroy, params: { id: workshop.id }
          end

          expect(flash[:notice]).to eq(I18n.t('admin.workshop.destroy.failure'))
        end
      end
    end
  end

  describe 'GET #new' do
    render_views

    it 'renders with native date and time inputs for main and RSVP fields' do
      get :new

      expect(response.body).to include('type="date"')
      expect(response.body).to include('type="time"')
      expect(response.body.scan('type="date"').size).to be >= 3 # main date + RSVP open + RSVP close
      expect(response.body.scan('type="time"').size).to be >= 3 # main time + RSVP open + RSVP close
    end
  end

  describe 'GET #edit' do
    render_views

    it 'pre-fills main date and time values in ISO format' do
      get :edit, params: { id: workshop.id }

      expect(response.body).to include("value=\"#{workshop.date_and_time.strftime('%Y-%m-%d')}\"")
      expect(response.body).to include("value=\"#{workshop.time.strftime('%H:%M')}\"")
    end

    context 'with RSVP windows set' do
      let(:workshop) do
        Fabricate(:workshop,
                  rsvp_opens_at: 1.day.from_now,
                  rsvp_closes_at: 2.days.from_now)
      end

      it 'pre-fills RSVP date and time values in ISO format' do
        get :edit, params: { id: workshop.id }

        expect(response.body).to include("value=\"#{workshop.rsvp_opens_at.strftime('%Y-%m-%d')}\"")
        expect(response.body).to include("value=\"#{workshop.rsvp_opens_at.strftime('%H:%M')}\"")
        expect(response.body).to include("value=\"#{workshop.rsvp_closes_at.strftime('%Y-%m-%d')}\"")
        expect(response.body).to include("value=\"#{workshop.rsvp_closes_at.strftime('%H:%M')}\"")
      end
    end
  end
end
