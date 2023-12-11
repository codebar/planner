require 'spec_helper'

RSpec.describe Member::DetailsController, type: :controller do
  describe "GET edit" do
    context "When a user is not logged in" do
      it "redirects to GitHub authentication" do
        get :edit
        expect(response).to redirect_to("/auth/github")
      end
    end
  end
end
