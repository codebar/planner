class SubscriptionsController < ApplicationController
  before_action :has_access?

  def index
    @groups = Group.includes(:chapter).references(:chapter).order('chapters.city')
  end

  def create
    @subscription = Subscription.new(group_id: group_id, member: current_user)

    respond_to do |format|
      if @subscription.save
        unless current_user.received_welcome_for?(@subscription)
          MemberMailer.welcome_for_subscription(@subscription).deliver_now
        end
        format.html do
          flash[:notice] = "You have subscribed to #{@subscription.group.chapter.city}'s #{@subscription.group.name} group"
          redirect_to :back
        end
        format.js { render 'create_success' }
      else
        flash[:notice] = @subscription.errors.full_messages.join('<br/>')
        format.html { redirect_to :back }
        format.js { render 'create_error' }
      end
    end
  end

  def destroy
    @subscription = current_user.subscriptions.find_by(group_id: group_id)
    @subscription.destroy

    respond_to do |format|
      format.html do
        flash[:notice] = "You have unsubscribed from #{@subscription.group.chapter.city}'s #{@subscription.group.name} group"
        redirect_to :back
      end
      format.js
    end
  end

  private

  def group_id
    params.require(:subscription).permit(:group_id)[:group_id]
  end
end
