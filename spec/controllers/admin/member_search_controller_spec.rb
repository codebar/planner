RSpec.describe Admin::MemberSearchController, type: :controller do
  let(:member) {Fabricate.build(:member)}

  describe 'GET #index' do
    context "when user is not logged in" do
      before do
        get :index
      end
      it "redirects to the home page" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when user is an admin" do
      let(:fake_relation) { instance_double('ActiveRecord::Relation') }
      let(:fake_juliet) { instance_double('Member', id: 1, name: 'Juliet', surname: 'Montague') }

      before do
        login_as_admin(member)
        get :index
      end
      it "shows user the search page" do
        expect(response).to have_http_status(:ok)
      end

      context "and when admin user searches for a single existing user" do
        before do
          allow(Member).to receive(:find_members).with('Juliet').and_return(fake_relation)
          allow(fake_relation).to receive(:select).with(any_args).and_return([fake_juliet])
          get :index, params: {member_search: {name: "Juliet", callback_url: root_path}}
        end
        it "redirects to the calling service" do
          expect(response).to have_http_status(:found)

          uri = URI.parse(response.location)
          redirect_params = Rack::Utils.parse_nested_query(uri.query)

          expect(redirect_params["member_pick"]["members"]).to eq(["1"])
        end
      end

      context "and when an admin user searches and there are multiple results" do
      let(:fake_romeo) { double('Member', id: 2, name: 'Romeo', surname: 'Capulet')}

        before do
          allow(Member).to receive(:find_members).with('e').and_return(fake_relation)
          allow(fake_relation).to receive(:select).with(any_args).and_return([fake_juliet, fake_romeo])
          get :index, params: {member_search: {name: 'e', callback_url: root_path}}
        end
        it "presents the found members on the index page" do
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
