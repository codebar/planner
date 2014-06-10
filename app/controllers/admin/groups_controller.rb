class Admin::GroupsController < Admin::ApplicationController

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      flash[:notice] = "Group #{@group.name} for chapter #{@group.chapter.name} has been succesfuly created"
      redirect_to [ :admin, @group ]
    else
      flash[:notice] = @group.errors.full_messages
      render 'new'
    end
  end

  def show
    @group = Group.find(params[:id])
  end

  private
  def group_params
    params.require(:group).permit(:name, :description, :chapter_id)
  end
end
