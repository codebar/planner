class Admin::BansController < Admin::ApplicationController

  def new
    @member = Member.find(member_id)
    @ban = Ban.new
  end

  def create
    @member = Member.find(member_id)

    @ban = @member.bans.build(ban_params)
    puts @ban.inspect
    @ban.added_by = current_user

    if @ban.save
      redirect_to [:admin, @member], notice: 'The user has been baned'
    else
      render 'new'
    end
  end

  private

  def ban_params
    params.require(:ban).permit(:note, :reason, :permanent, :expires_at)
  end

  def member_id
    params[:member_id]
  end
end
