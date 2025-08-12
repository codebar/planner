RSpec.describe AuthServicesController do
  describe "GET #new" do
    it "redirects when referer is missing" do
      expected_referer_path = nil
      request.env["HTTP_REFERER"] = expected_referer_path

      get :new
      expect(response).to redirect_to("/auth/github")
      expect(session[:referer_path]).to eq(expected_referer_path)
    end

    it "redirects when referer is present" do
      expected_referer_path = "workshops/42"
      request.env["HTTP_REFERER"] = expected_referer_path

      get :new
      expect(response).to redirect_to("/auth/github")
      expect(session[:referer_path]).to eq(expected_referer_path)
    end
  end
end
