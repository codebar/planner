class Admin::GroupsController < Admin::ApplicationController
  after_action :verify_authorized

  def show
    @group = Group.find(params[:id])
    authorize @group

    @eligible_count = @group.eligible_members.count
    @total_count = @group.members.count
    @pagy, @members = pagy(Group.members_by_recent_rsvp(@group), items: 20)
  end
end
