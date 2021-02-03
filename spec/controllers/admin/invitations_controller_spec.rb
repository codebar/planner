require "spec_helper"

RSpec.describe Admin::InvitationsController, type: :controller do
  let(:invitation) { Fabricate(:student_workshop_invitation) }
  let(:workshop) { invitation.workshop }
  let(:admin) { Fabricate(:chapter_organiser) }

  describe "PUT #update" do
    before do
      admin.add_role(:organiser, workshop.chapter)

      login admin
      request.env["HTTP_REFERER"] = "/admin/member/3"

      expect(invitation.attending).to be_nil
    end

    it "Successfuly updates an invitation" do
      put :update, id: invitation.token, workshop_id: workshop.id, attending: "true"
      
      expect(invitation.reload.attending).to be true
      expect(flash[:notice]).to match("You have added")
    end

    it "Warns the user about failed updates" do
      # Trigger an error when trying to update the `attending` attribute
      invitation.update_attribute(:tutorial, nil)

      put :update, id: invitation.token, workshop_id: workshop.id, attending: "true"
      
      # State didn't change and we have an error message explaining why
      expect(invitation.reload.attending).to be_nil
      expect(flash[:notice]).to match("Tutorial must be selected.")
    end
  end
end
