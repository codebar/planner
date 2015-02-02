class Admin::MembersController < Admin::ApplicationController

  def show
    @member = Member.includes(:member_notes).find(params[:id])
  end
end
