class SubscriptionsController < ApplicationController
  before_action :has_access?

  def index
    @groups = Group.includes(:chapter).references(:chapter).order('chapters.city')
  end

  def create
    @subscription = Subscription.new(group_id: group_id, member: current_user)

    if @subscription.save
      unless current_user.received_welcome_for?(@subscription)
        MemberMailer.welcome_for_subscription(@subscription).deliver_now
      end
      flash[:notice] = "You have subscribed to #{@subscription.group.chapter.city}'s #{@subscription.group.name} group"
    else
      flash[:notice] = @subscription.errors.inspect
    end
    redirect_to :back
  end

  def destroy
    @subscription = current_user.subscriptions.find_by(group_id: group_id)
    @subscription.destroy
    flash[:notice] = "You have unsubscribed from #{@subscription.group.chapter.city}'s #{@subscription.group.name} group"

    redirect_to :back
  end

  private

  def group_id
    params.require(:subscription).permit(:group_id)[:group_id]
  end
end
