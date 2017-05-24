require 'spec_helper'

RSpec.describe EventsController, type: :controller do
  
  describe '#index' do
    
    let!(:workshops) { 
      15.times.map { Fabricate(:workshop, date_and_time: 1.week.ago) }
    }
    
    it 'returns only recent events' do
      get :index
      expect(assigns(:past_events).first.second.length).to be Listable::NUMBER_RECORDS_TO_RETRIEVE
    end
    
  end

end
