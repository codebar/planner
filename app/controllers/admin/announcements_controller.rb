class Admin::AnnouncementsController < Admin::ApplicationController
  before_action :set_announcement, only: [:update, :edit]

  def index
    @announcements = Announcement.all
  end

  def new
    @announcement = Announcement.new
  end

  def create
    @announcement = Announcement.new(announcement_params.merge!(created_by: current_user))
    redirect_to dashboard_path, notice: 'Announcement successfully created' if @announcement.save
  end

  def update
    @announcement.update_attributes(announcement_params)
    redirect_to dashboard_path
  end

  def edit; end

  private

  def set_announcement
    @announcement = Announcement.find(params[:id])
  end

  def announcement_params
    params.require(:announcement).permit(:message, :expires_at, group_ids: [])
  end
end
