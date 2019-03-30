require 'spec_helper'

describe MembersController, type: :controller do
  describe 'GET unsubscribe/#token' do
    it 'redirects to the subscription path when token is valid' do
      member = Fabricate(:member)
      get :unsubscribe, params: { token: member_token(member) }
      expect(response).to redirect_to(subscriptions_path)
    end

    it 'redirects to the root path when token is invalid' do
      get :unsubscribe, params: { token: 'foo' }
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq('Your token is invalid. ')
    end
  end
end
