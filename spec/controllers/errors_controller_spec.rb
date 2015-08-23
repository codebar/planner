require 'spec_helper'

describe ErrorsController, type: :controller do
  describe "error404" do
    it "renders not found status" do
      get :error404
      expect(response.status).to eq(404)
      expect(response).to render_template(:error404)
    end
  end

  describe "error500" do
    it "renders internal error status" do
      get :error500
      expect(response.status).to eq(500)
      expect(response).to render_template(:error500)
    end
  end
end