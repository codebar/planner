class Admin::BansController < Admin::ApplicationController
  before_action :set_member

  def new
    @ban = Ban.new
  end

  def create
    @ban = @member.bans.build(ban_params)
    @ban.added_by = current_user

    if @ban.save
      MemberMailer.ban(@ban.member, @ban).deliver_now
      redirect_to [:admin, @member], notice: t('.success')
    else
      render 'new'
    end
  end

  private

  def ban_params
    params.require(:ban).permit(:note, :reason, :permanent, :expires_at, :explanation)
  end

  def set_member
    @member = Member.find(params[:member_id])
  end
end
