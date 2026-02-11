class Admin::AnnouncementsController < SuperAdmin::ApplicationController
  before_action :set_announcement, only: %i[update edit]

  def index
    @announcements = Announcement.includes(:created_by).includes(:groups).all
  end

  def new
    @announcement = Announcement.new
  end

  def create
    @announcement = Announcement.new(announcement_params.merge!(created_by: current_user))
    if announcement_params[:all_groups]
      group_ids = Group.joins(:chapter).where(chapters: { active: true }).pluck(:id)
      @announcement.group_ids = group_ids
    end

    return redirect_to admin_announcements_path, notice: 'Announcement successfully created' if @announcement.save

    flash['notice'] = 'Please make sure you fill in all mandatory fields'
    render 'new'
  end

  def update
    @announcement.update(announcement_params)
    redirect_to admin_announcements_path, notice: 'Announcement successfully updated'
  end

  def edit; end

  private

  def set_announcement
    @announcement = Announcement.find(params[:id])
  end

  def announcement_params
    params.expect(announcement: [:all_groups, :message, :expires_at, { group_ids: [] }])
  end
end
