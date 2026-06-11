RSpec.describe FeedbackController do
  let(:feedback_request) { Fabricate(:feedback_request) }
  let(:coach) { Fabricate(:coach) }
  let(:tutorial) { Fabricate(:tutorial) }

  describe 'GET #show' do
    context 'with a valid token' do
      it 'renders the feedback form' do
        get :show, params: { id: feedback_request.token }
        expect(response).to have_http_status(:success)
      end
    end

    context 'with an already submitted token' do
      it 'redirects to the root path' do
        submitted_request = Fabricate(:feedback_request, submited: true)
        get :show, params: { id: submitted_request.token }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PATCH #submit' do
    before do
      Fabricate(:attended_workshop_invitation, workshop: feedback_request.workshop, member: coach, role: 'Coach')
    end

    context 'with valid data' do
      it 'saves the feedback and redirects to the root path' do
        patch :submit, params: {
          id: feedback_request.token,
          feedback: {
            coach_id: coach.id,
            tutorial_id: tutorial.id,
            request: 'It was great!',
            rating: 5,
            suggestions: ''
          }
        }

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t('messages.feedback_saved'))
        expect(feedback_request.reload.submited).to be true
      end
    end

    context 'with invalid data' do
      it 'renders the feedback form with errors' do
        patch :submit, params: {
          id: feedback_request.token,
          feedback: {
            coach_id: coach.id,
            tutorial_id: tutorial.id,
            request: '',
            rating: nil,
            suggestions: ''
          }
        }

        expect(response).to have_http_status(:success)
        expect(flash[:alert]).to include("Rating can't be blank")
      end
    end

    context 'without a CSRF token (browser did not send session cookie)' do
      it 'still accepts the feedback submission' do
        # Simulate the real-world scenario where the browser withholds the
        # session cookie (e.g. Safari ITP, cross-site navigation, or cookie
        # blocking). With protect_from_forgery enabled, this would normally
        # raise ActionController::InvalidAuthenticityToken.
        ActionController::Base.allow_forgery_protection = true

        patch :submit, params: {
          id: feedback_request.token,
          feedback: {
            coach_id: coach.id,
            tutorial_id: tutorial.id,
            request: 'It was great!',
            rating: 5,
            suggestions: ''
          }
        }

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t('messages.feedback_saved'))
        expect(feedback_request.reload.submited).to be true
      ensure
        ActionController::Base.allow_forgery_protection = false
      end
    end
  end
end
