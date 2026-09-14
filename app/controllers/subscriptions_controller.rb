class SubscriptionsController < ApplicationController
  before_action :require_access

  def index
    @mailing_list = MailingListForm.new
    @groups = Group.where(chapter: { active: true }).order('chapter.city')
    @member = MemberPresenter.new(current_user)
  end

  def create # rubocop:disable Metrics/MethodLength
    subscription = Subscription.new(group_id:, member: current_user)

    if subscription.save
      SubscriptionMailingListService.subscribe(subscription)
      MemberActivityRecorder.record(actor: current_user, key: 'subscription.created',
                                    trackable: subscription.group)
      send_welcome_email(current_user, subscription)
      flash[:notice] = I18n.t('subscriptions.messages.group.subscribe', chapter: subscription.group.chapter.city,
                                                                        role: subscription.group.name)
    else
      flash[:notice] = subscription.errors.inspect
    end
    redirect_back fallback_location: root_path
  end

  def destroy # rubocop:disable Metrics/MethodLength
    # Don't error if subscription is not found
    subscription = current_user.subscriptions.find_by(group_id:)
    SubscriptionMailingListService.unsubscribe(subscription) if subscription
    subscription&.destroy

    group = Group.find(group_id)
    if subscription
      MemberActivityRecorder.record(actor: current_user, key: 'subscription.removed',
                                    trackable: group)
    end

    flash[:notice] = I18n.t('subscriptions.messages.group.unsubscribe',
                            chapter: group.chapter.city,
                            role: group.name)

    redirect_back fallback_location: root_path
  end

  private

  def group_id
    params.expect(subscription: [:group_id])[:group_id]
  end

  def send_welcome_email(member, subscription)
    return if member.received_welcome_for?(subscription)

    MemberMailer.welcome_for_subscription(subscription).deliver_now
  end
end
