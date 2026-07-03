# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::CheckInsController do
  let(:admin) { Fabricate(:member) }
  let(:event) { Fabricate(:event) }

  before { login_as_admin(admin) }

  describe "GET show" do
    it "renders the instructions page" do
      get :show, params: { event_id: event.slug }
      expect(response).to be_successful
    end

    it "returns PDF for .pdf format" do
      get :show, params: { event_id: event.slug, format: :pdf }
      expect(response.content_type).to eq("application/pdf")
    end
  end
end
