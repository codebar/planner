require 'rails_helper'

RSpec.describe Admin::MembersController, type: :controller do
  describe 'GET #search' do
    let(:admin) { Fabricate(:member) }
    let!(:member_jane) { Fabricate(:member, name: 'Jane', surname: 'Doe', email: 'jane@example.com', pronouns: nil) }
    let!(:member_john) { Fabricate(:member, name: 'John', surname: 'Smith', email: 'john@test.com') }

    before do
      admin.add_role(:admin)
      login_as_admin(admin)
    end

    context 'with query less than 3 characters' do
      it 'returns empty array' do
        get :search, params: { q: 'ab' }, format: :json

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq([])
      end
    end

    context 'with query 3 or more characters' do
      it 'returns matching members by name' do
        get :search, params: { q: 'Jane Doe' }, format: :json

        expect(response).to have_http_status(:ok)
        results = JSON.parse(response.body)
        expect(results.length).to eq(1)
        expect(results.first['id']).to eq(member_jane.id)
        expect(results.first['full_name']).to eq('Jane Doe')
      end

      it 'returns matching members by email' do
        get :search, params: { q: 'john@test.com' }, format: :json

        expect(response).to have_http_status(:ok)
        results = JSON.parse(response.body)
        expect(results.length).to eq(1)
        expect(results.first['id']).to eq(member_john.id)
      end

      it 'returns JSON with correct shape' do
        get :search, params: { q: 'Jane Doe' }, format: :json

        results = JSON.parse(response.body)
        expect(results.first.keys).to contain_exactly('id', 'name', 'surname', 'email', 'full_name')
      end

      it 'limits results to 50' do
        51.times { |i| Fabricate(:member, name: "Test#{i}", surname: 'User', email: "test#{i}@example.com") }

        get :search, params: { q: 'Test' }, format: :json

        results = JSON.parse(response.body)
        expect(results.length).to be <= 50
      end
    end

    context 'when not authenticated' do
      before { login(Fabricate(:member)) }

      it 'redirects to login' do
        get :search, params: { q: 'test' }, format: :json

        expect(response).to have_http_status(:found)
      end
    end
  end

  describe 'GET #send_attendance_email' do
    let(:member) { Fabricate(:member) }
    let(:admin) { Fabricate(:member) }

    before do
      admin.add_role(:admin)
      login_as_admin(admin)
    end

    it 'creates an attendance warning' do
      expect {
        get :send_attendance_email, params: { member_id: member.id }
      }.to change(AttendanceWarning, :count).by(1)
    end

    it 'sends an attendance warning email' do
      mailer = double(deliver_now: true)
      expect(MemberMailer).to receive(:attendance_warning)
        .with(member, member.email)
        .and_return(mailer)

      get :send_attendance_email, params: { member_id: member.id }
    end

    it 'redirects to the member page' do
      get :send_attendance_email, params: { member_id: member.id }

      expect(response).to redirect_to([:admin, member])
    end

    context 'when not authenticated' do
      before { login(Fabricate(:member)) }

      it 'redirects to login' do
        get :send_attendance_email, params: { member_id: member.id }

        expect(response).to have_http_status(:found)
      end
    end
  end

  describe 'GET #send_eligibility_email' do
    let(:member) { Fabricate(:member) }
    let(:admin) { Fabricate(:member) }

    before do
      admin.add_role(:admin)
      login_as_admin(admin)
    end

    it 'creates an eligibility inquiry' do
      expect {
        get :send_eligibility_email, params: { member_id: member.id }
      }.to change(EligibilityInquiry, :count).by(1)
    end

    it 'sends an eligibility check email' do
      mailer = double(deliver_now: true)
      expect(MemberMailer).to receive(:eligibility_check)
        .with(member, member.email)
        .and_return(mailer)

      get :send_eligibility_email, params: { member_id: member.id }
    end

    it 'redirects to the member page' do
      get :send_eligibility_email, params: { member_id: member.id }

      expect(response).to redirect_to([:admin, member])
    end

    context 'when not authenticated' do
      before { login(Fabricate(:member)) }

      it 'redirects to login' do
        get :send_eligibility_email, params: { member_id: member.id }

        expect(response).to have_http_status(:found)
      end
    end
  end
end
