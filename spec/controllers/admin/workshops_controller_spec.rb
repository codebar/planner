require 'spec_helper'

describe Admin::WorkshopsController, type: :controller do
  let(:admin) { Fabricate(:chapter_organiser) }
  let!(:workshop) { Fabricate(:sessions) }
  let(:member) { Fabricate(:member) }

  before :each do
    login admin
  end

  describe "DELETE #destroy" do
    context "workshop invitations have been sent" do

      before :each do
        Fabricate(:student_session_invitation, member: member, sessions: workshop, attending: true)
      end

      context "workshop deletion tried within specific time frame since it's creation" do
        it "should not delete the workshop" do
          expect {
            delete :destroy, id: workshop.id
          }.not_to change {Sessions.count}
        end

        it "should display workshop can't be deleted related flash message" do
          delete :destroy, id: workshop.id

          expect(flash[:notice]).to eq("Workshop cannot be deleted. This is because it has invitees" \
                                       " and/or workshop information is on the website for a while " \
                                       "long enough that it cannot be deleted.")
        end
      end

      context "workshop deletion tried outside specific time frame since it's creation" do
        it "should not delete the workshop" do
          new_current_time = 1.day + Admin::WorkshopsController::
                                     WORKSHOP_DELETION_TIME_FRAME_SINCE_CREATION

          Timecop.travel(new_current_time)
          expect {
            delete :destroy, id: workshop.id
          }.not_to change {Sessions.count}
          Timecop.return
        end

        it "should display workshop can't be deleted related flash message" do
          new_current_time = 1.day + Admin::WorkshopsController::
                                     WORKSHOP_DELETION_TIME_FRAME_SINCE_CREATION

          Timecop.travel(new_current_time)
          delete :destroy, id: workshop.id
          Timecop.return

          expect(flash[:notice]).to eq("Workshop cannot be deleted. This is because it has invitees" \
                                       " and/or workshop information is on the website for a while " \
                                       "long enough that it cannot be deleted.")
        end

      end
    end

    context "workshop invitations haven't been sent" do
      context "workshop deletion tried within specific time frame since it's creation" do
        it "should successfully delete the workshop" do
          expect {
            delete :destroy, id: workshop.id
          }.to change{Sessions.count}.by -1
        end

        it "should display workshop deleted successfully related flash message" do
          delete :destroy, id: workshop.id

          expect(flash[:notice]).to eq("Workshop deleted succesfully")
        end
      end

      context "workshop deletion tried outside specific time frame since it's creation" do
        it "should not delete the workshop" do
          new_current_time = 1.day + Admin::WorkshopsController::
                                     WORKSHOP_DELETION_TIME_FRAME_SINCE_CREATION

          Timecop.travel(new_current_time)
          expect {
            delete :destroy, id: workshop.id
          }.not_to change {Sessions.count}
          Timecop.return
        end

        it "should display workshop can't be deleted related flash message" do
          new_current_time = 1.day + Admin::WorkshopsController::
                                     WORKSHOP_DELETION_TIME_FRAME_SINCE_CREATION

          Timecop.travel(new_current_time)
          delete :destroy, id: workshop.id
          Timecop.return

          expect(flash[:notice]).to eq("Workshop cannot be deleted. This is because it has invitees" \
                                       " and/or workshop information is on the website for a while " \
                                       "long enough that it cannot be deleted.")
        end
      end
    end
  end
end