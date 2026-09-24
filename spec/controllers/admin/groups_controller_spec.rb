require 'rails_helper'

RSpec.describe Admin::GroupsController do
  let(:admin) { Fabricate(:member) }
  let(:group) { Fabricate(:group) }

  def assigns(symbol)
    controller.instance_variable_get("@#{symbol}")
  end

  before do
    login_as_admin(admin)
  end

  describe 'GET #show' do
    render_views

    it 'paginates members at 20 per page with a second page available' do
      21.times do |i|
        member = Fabricate(:member, name: "Group#{i}", surname: 'Member')
        Fabricate(:subscription, member:, group:)
      end

      get :show, params: { id: group.id }

      expect(assigns(:pagy).pages).to eq(2)
      expect(assigns(:members).size).to eq(20)
      expect(response.body).to include('page=2')

      get :show, params: { id: group.id, page: 2 }

      expect(assigns(:members).size).to eq(1)
      expect(assigns(:members).first.name).to start_with('Group')
    end
  end
end
