class Admin::InvitationsController < Admin::ApplicationController
  include Admin::WorkshopConcerns

  def update
    @attendance_manager = Managers::AttendanceManager.new(params[:workshop_id], invitation_id, current_user)
    @workshop = WorkshopPresenter.decorate(@attendance_manager.workshop)
    authorize @workshop
    @invitation = @attendance_manager.invitation
    message = @attendance_manager.update(attending: is_attending?, attended: params[:attended])

    if request.xhr?
      set_admin_workshop_data
      render partial: 'admin/workshops/invitation_management'
    else
      redirect_back fallback_location: root_path, notice: message
    end
  end

  private

  def is_attending?
    ActiveRecord::Type::Boolean.new.cast(params[:attending])
  end

  def invitation_id
    params.key?(:workshop) ? params[:workshop][:invitations] : params[:id]
  end
end
