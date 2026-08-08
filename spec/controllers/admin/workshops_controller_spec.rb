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

  describe 'GET #show' do
    it 'loads the workshop attendance page with attendees' do
      Fabricate(:workshop_invitation, workshop: workshop, attending: true)
      get :show, params: { id: workshop.id }

      expect(response).to have_http_status(:success)
    end

    it 'loads the attendance page in a bounded number of queries, regardless of attendee count' do
      attendee = Fabricate(:member)
      4.times { Fabricate(:past_attending_workshop_invitation, member: attendee) }
      2.times { Fabricate(:attendance_warning, member: attendee) }
      Fabricate(:member_note, member: attendee, created_at: 1.day.ago)
      Fabricate(:workshop_invitation, workshop: workshop, member: attendee, attending: true, role: 'Student')
      Fabricate(:workshop_invitation, workshop: workshop, attending: true, role: 'Coach')

      # adds a second attendee to catch per-row scaling
      Fabricate(:workshop_invitation, workshop: workshop, attending: true, role: 'Student')

      count = count_queries { get :show, params: { id: workshop.id } }

      expect(response).to have_http_status(:success)
      expect(count).to be < 50
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
        Fabricate(:attending_workshop_invitation, workshop: workshop)
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
end
