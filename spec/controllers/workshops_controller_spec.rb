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

  describe "POST #remove" do
    it "Redirects to the login page if the user's logged out" do
      post :remove, id: workshop.id
      expect(response).to redirect_to '/auth/github'
    end

    it "Does nothing if the student has no invite or waiting list" do
      login member
      post :remove, id: workshop.id
      expect(response).to redirect_to removed_workshop_path(workshop)
    end

    it "Removes a student from the attendees, if the user's got an invite"
    it "Removes a student from the waiting list, if the user's on the waiting list"
    it "Removes both invites if the student has somehow got both a student and coach invite" do
      Fabricate(:student_session_invitation, member: member, sessions: workshop, attending: true)
      Fabricate(:coach_session_invitation, member: member, sessions: workshop, attending: true)
      expect(workshop.attendee? member).to be true

      login member
      post :remove, id: workshop.id
      expect(workshop.attendee? member).to be false
    end
  end
end
