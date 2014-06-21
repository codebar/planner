class SubscriptionsController < ApplicationController
  before_action :has_access?

  def index
    @groups = Group.joins(:chapter).order("chapters.city")
  end

  def create
    @subscription = Subscription.new(group_id: subscription_params[:group_id], member: current_user)
    if @subscription.save
      flash[:notice] = "You have subscribed to #{@subscription.group.chapter.city}'s #{@subscription.group.name} group"
    else
      flash[:notice] = @subscription.errors.inspect
    end
    redirect_to :back
  end

  def destroy
    @subscription = current_user.subscriptions.find_by_group_id(subscription_params[:group_id])
    @subscription.destroy
    flash[:notice] = "You have unsubscribed from #{@subscription.group.chapter.city}'s #{@subscription.group.name} group"
    redirect_to :back
  end

  private
  def subscription_params
    params.require(:subscription).permit(:group_id)
  end
end
