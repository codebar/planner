require 'spec_helper'

describe WorkshopsController, type: :controller do
  let(:workshop) { Fabricate(:sessions) }
  let(:member) { Fabricate(:member) }

  describe "POST #add" do
    it "Redirects to the login page if the user's logged out" do
      post :add, id: workshop.id
      expect(response).to redirect_to '/auth/github'
    end

    it "Adds a student to the attendees, if the user's a student and there's space" do
      login member
      post :add, {id: workshop.id, role: 'student'}
      expect(response).to redirect_to :added_workshop
    end

    it "Adds a student to the waiting list, if the user's a student and there's no space" do
      login member
      expect_any_instance_of(Sessions).to receive(:student_spaces?).and_return(false)

      post :add, {id: workshop.id, role: 'student'}
      expect(response).to redirect_to :waitlisted_workshop
    end

    it "Adds a coach to the attendees, if the user's a coach and there's space" do
      login member
      post :add, {id: workshop.id, role: 'coach'}
      expect(response).to redirect_to :added_workshop
    end

    it "Adds a coach to the waiting list, if the user's a coach and there's no space" do
      login member
      expect_any_instance_of(Sessions).to receive(:coach_spaces?).and_return(false)

      post :add, {id: workshop.id, role: 'coach'}
      expect(response).to redirect_to :waitlisted_workshop
    end

    it "Redirects back to the event page if we have no idea whether the user's a coach or a student" do
      login member

      post :add, {id: workshop.id}
      expect(response).to redirect_to :workshop
    end
  end
end
