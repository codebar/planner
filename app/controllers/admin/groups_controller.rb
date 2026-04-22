class Admin::GroupsController < Admin::ApplicationController
  after_action :verify_authorized

  def new
    @group = Group.new
    authorize @group
  end

  def create
    @group = Group.new(group_params)
    authorize @group

    if @group.save
      flash[:notice] = "Group #{@group.name} for chapter #{@group.chapter.name} has been successfully created"
      redirect_to [:admin, @group]
    else
      flash[:notice] = @group.errors.full_messages
      render 'new'
    end
  end

  def show
    @group = Group.find(params[:id])
    authorize @group

    @eligible_count = @group.eligible_members.count
    @total_count = @group.members.count
    @pagy, @members = pagy(Group.members_by_recent_rsvp(@group), items: 20)
  end

  private

  def group_params
    params.expect(group: %i[name description chapter_id])
  end
end
