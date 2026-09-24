require 'rails_helper'

RSpec.describe DashboardController do
  def assigns(symbol)
    controller.instance_variable_get("@#{symbol}")
  end

  describe 'GET #wall_of_fame' do
    render_views

    it 'paginates coaches at 20 per page with a second page available' do
      workshop = Fabricate(:workshop, date_and_time: Time.zone.now)
      21.times do |i|
        Fabricate(:attended_coach,
                  member: Fabricate(:member, name: "Coach#{i}", surname: 'Wall'),
                  workshop:)
      end

      get :wall_of_fame

      expect(assigns(:pagy).pages).to eq(2)
      expect(assigns(:coaches).size).to eq(20)
      expect(response.body).to include('page=2')

      get :wall_of_fame, params: { page: 2 }

      expect(assigns(:coaches).size).to eq(1)
      expect(assigns(:coaches).first.name).to start_with('Coach')
    end
  end
end
