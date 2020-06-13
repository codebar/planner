module WorkshopInvitationConcerns
  extend ActiveSupport::Concern

  included do
    before_action :set_invitation

    include InstanceMethods
  end

  module InstanceMethods
    private

    def invitation_params
      params[:workshop_invitation].present? ? params.require(:workshop_invitation).permit(:tutorial, :note) : {}
    end

    def back_with_message(message)
      redirect_back(fallback_location: invitation_path(@invitation), notice: message)
    end

    def set_invitation
      @invitation = WorkshopInvitation.find_by(token: token)
    end
  end
end
