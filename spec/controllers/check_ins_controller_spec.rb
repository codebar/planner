# frozen_string_literal: true

require "rails_helper"

RSpec.describe CheckInsController do
  let(:member) { Fabricate(:member) }
  let(:event) { Fabricate(:event) }

  describe "GET new" do
    it "renders the role selection page when logged in" do
      login(member)
      get :new, params: { code: event.check_in_code }
      expect(response).to be_successful
    end

    it "redirects to auth when not logged in" do
      get :new, params: { code: event.check_in_code }
      expect(response).to redirect_to("/auth/github")
    end
  end

  describe "POST create" do
    before { login(member) }

    it "creates an invitation with source=check_in" do
      post :create, params: { code: event.check_in_code, role: "Student" }
      invitation = Invitation.last
      expect(invitation.source).to eq("check_in")
      expect(invitation.attending).to be true
      expect(invitation.verified).to be true
    end
  end
end
