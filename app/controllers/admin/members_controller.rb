class Admin::MembersController < Admin::ApplicationController
  def index
    @members = Member.all
  end

  def show
    @member = Member.includes(:member_notes).find(params[:id])
    @invitations = @member.session_invitations.accepted_or_attended.order_by_latest rescue nil
    @monthly_invitations = @member.meeting_invitations.order(:created_at) rescue nil
    @last_attendance = @invitations.first.workshop if @invitations.any?
    @member_note = MemberNote.new
  end

  def update_subscriptions
    member = Member.find(params[:member_id])
    subscription = member.subscriptions.find_by_group_id(params[:group])
    flash[:notice] = "You have unsubscribed #{member.full_name} from #{subscription.group.chapter.city}'s #{subscription.group.name} group"

    subscription.destroy
    redirect_to :back
  end

  def send_eligibility_email
    @member = Member.find(params[:member_id])
    @member.send_eligibility_email(current_user)
    redirect_to [:admin, @member], notice: "You have sent an eligibility confirmation request."
  end

  def send_attendance_email
    @member = Member.find(params[:member_id])
    @member.send_attendance_email(current_user)
    redirect_to [:admin, @member], notice: "You have sent an attendance warning."
  end
end
