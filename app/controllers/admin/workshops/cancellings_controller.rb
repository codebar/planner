module Admin::Workshops
  class CancellingsController < Admin::ApplicationController
    before_action :set_workshop

    def create
      @workshop.update_column(:cancelled, true)
      redirect_to admin_workshop_path(@workshop)
    end

     private

      def set_workshop
        @workshop = Workshop.find(params[:workshop_id])
      end
  end
end
