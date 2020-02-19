class SubscriptionsController < ApplicationController
  before_action :has_access?

  def index
    @groups = Group.includes(:chapter).references(:chapter).order('chapters.city')
  end

  def create
    @subscription = Subscription.new(group_id: group_id, member: current_user)

    respond_to do |format|
      if @subscription.save
        send_welcome_unless_already_sent
        flash[:notice] = t('messages.subscriptions.create.success', subscription_city_and_name)
        format.html { redirect_to :back }
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
        flash[:notice] = t('messages.subscriptions.destroy.success', subscription_city_and_name)
        redirect_to :back
      end
      format.js
    end
  end

  private

  def send_welcome_unless_already_sent
    return if current_user.received_welcome_for?(@subscription)

    MemberMailer.welcome_for_subscription(@subscription).deliver_now
  end

  def subscription_city_and_name
    {
      city: @subscription.group.chapter.city,
      name: @subscription.group.name
    }
  end

  def group_id
    params.require(:subscription).permit(:group_id)[:group_id]
  end
end
