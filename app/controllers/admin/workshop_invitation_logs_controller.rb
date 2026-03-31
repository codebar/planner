module Admin
  class WorkshopInvitationLogsController < Admin::ApplicationController
    def index
      @workshop = Workshop.find(params[:workshop_id])
      authorize @workshop, :show?
      logs = InvitationLog.where(loggable: @workshop)
                          .order(created_at: :desc)
                          .includes(:initiator, :entries)
      @pagy, @logs = pagy(logs)
    end

    def show
      @workshop = Workshop.find(params[:workshop_id])
      authorize @workshop, :show?
      @log = InvitationLog.find(params[:id])
      @entries = @log.entries.order(processed_at: :desc).includes(:member)
    end
  end
end
