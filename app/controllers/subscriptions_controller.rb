class SubscriptionsController < ApplicationController
  before_action :has_access?

  def index
    @mailing_list = MailingListForm.new
    @groups = Group.includes(:chapter).references(:chapter).order('chapters.city')
    @member = MemberPresenter.new(current_user)
  end

  def create
    @subscription = Subscription.new(group_id: group_id, member: current_user)

    if @subscription.save
      send_welcome_email(current_user, @subscription)
      flash[:notice] = I18n.t('subscriptions.messages.group.subscribe', chapter: @subscription.group.chapter.city,
                                                                        role: @subscription.group.name)
    else
      flash[:notice] = @subscription.errors.inspect
    end
    redirect_to :back
  end

  def destroy
    @subscription = current_user.subscriptions.find_by(group_id: group_id)
    @subscription.destroy

    flash[:notice] = I18n.t('subscriptions.messages.group.unsubscribe',
                            chapter: @subscription.group.chapter.city,
                            role: @subscription.group.name)

    redirect_to :back
  end

  private

  def group_id
    params.require(:subscription).permit(:group_id)[:group_id]
  end

  def send_welcome_email(member, subscription)
    return if member.received_welcome_for?(subscription)

    MemberMailer.welcome_for_subscription(subscription).deliver_now
  end
end
