class MembersController < ApplicationController
  before_action :logged_in?, only: [:edit, :show]

  def edit
    @member = current_member
  end

  def profile
    @member = current_member

    render :show
  end

  def update
    @member = current_member

    if @member.update_attributes(member_params)
      set_roles(@member)
      redirect_to root_path, notice: update_message(@member)
    else
      render "edit"
    end
  end

  def unsubscribe
    @member = Member.find(params[:id])
    @member.update_attribute(:unsubscribed, true)

    redirect_to root_path, notice: "You have been unsubscribed succesfully"
  end

  private

  def member_params
    params.require(:member).permit(:name, :surname, :email, :mobile, :twitter, :about_you, :role_ids)
  end

  def member_roles_params
    params[:member][:role_ids].delete("")
    params[:member][:role_ids]
  end

  def set_roles member
    member.role_ids = member_roles_params
  end

  def roles member
    member.roles.map { |r| r.name }.join(" and ")
  end

  def update_message member
    message = "Your details have been updated. "
    if member.roles.any?
      message << I18n.t("messages.member_notifications", roles: roles(member))
    else
      message << I18n.t("messages.no_roles")
    end
  end
end
