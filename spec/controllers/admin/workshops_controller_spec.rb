require 'spec_helper'

describe Admin::WorkshopsController, type: :controller do
  let!(:workshop) { Fabricate(:workshop) }
  let(:admin) { Fabricate(:member) }

  before do
    login_as_organiser(admin, workshop.chapter)
  end

  describe "DELETE #destroy" do
    context "workshop invitations have been sent" do

      before :each do
        Fabricate(:attending_session_invitation, workshop: workshop)
      end

      context "workshop deletion tried within specific time frame since it's creation" do
        it "should not delete the workshop" do
          expect {
            delete :destroy, id: workshop.id
          }.not_to change {Workshop.count}
        end

        it "should display workshop can't be deleted related flash message" do
          delete :destroy, id: workshop.id

          expect(flash[:notice]).to eq(I18n.t('admin.workshop.destroy.failure'))
        end
      end

      context "workshop deletion tried outside specific time frame since it's creation" do
        it "should not delete the workshop" do
          new_current_time = 1.day + Admin::WorkshopsController::
                                     WORKSHOP_DELETION_TIME_FRAME_SINCE_CREATION

          Timecop.travel(new_current_time)
          expect {
            delete :destroy, id: workshop.id
          }.not_to change {Workshop.count}
          Timecop.return
        end

        it "should display workshop can't be deleted related flash message" do
          new_current_time = 1.day + Admin::WorkshopsController::
                                     WORKSHOP_DELETION_TIME_FRAME_SINCE_CREATION

          Timecop.travel(new_current_time)
          delete :destroy, id: workshop.id
          Timecop.return

          expect(flash[:notice]).to eq(I18n.t('admin.workshop.destroy.failure'))
        end
      end
    end

    context "workshop invitations haven't been sent" do
      context "workshop deletion tried within specific time frame since it's creation" do
        it "should successfully delete the workshop" do
          expect {
            delete :destroy, id: workshop.id
          }.to change{Workshop.count}.by -1
        end

        it "should display workshop deleted successfully related flash message" do
          delete :destroy, id: workshop.id

          expect(flash[:notice]).to eq(I18n.t('admin.workshop.destroy.success'))
        end
      end

      context "workshop deletion tried outside specific time frame since it's creation" do
        it "should not delete the workshop" do
          new_current_time = 1.day + Admin::WorkshopsController::
                                     WORKSHOP_DELETION_TIME_FRAME_SINCE_CREATION

          Timecop.travel(new_current_time)
          expect {
            delete :destroy, id: workshop.id
          }.not_to change {Workshop.count}
          Timecop.return
        end

        it "should display workshop can't be deleted related flash message" do
          new_current_time = 1.day + Admin::WorkshopsController::
                                     WORKSHOP_DELETION_TIME_FRAME_SINCE_CREATION

          Timecop.travel(new_current_time)
          delete :destroy, id: workshop.id
          Timecop.return

          expect(flash[:notice]).to eq(I18n.t('admin.workshop.destroy.failure'))
        end
      end
    end
  end
end
