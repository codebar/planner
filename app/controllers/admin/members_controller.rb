class Admin::MembersController < Admin::ApplicationController

  def show
    @member = Member.find(params[:id])
  end
end
