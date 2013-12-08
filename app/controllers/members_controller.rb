class MembersController < ApplicationController

  def edit
    if current_member?
      @member = current_member
    else
      redirect_to "/auth/github"
    end
  end

  def update
    @member = current_member
    set_roles(@member)

    if @member.update_attributes(member_params)
      redirect_to root_path, notice: sign_up_message(@member)
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
    params.require(:member).permit(:name, :surname, :email, :twitter, :about_you, :role_ids)
  end

  def member_roles_params
    params[:member][:role_ids].delete("")
    params[:member][:role_ids]
  end

  def set_roles member
    member_roles_params.each { |role| member.roles << Role.find(role) }
  end

  def roles member
    member.roles.map { |r| r.name.pluralize }.join(", ")
  end

  def sign_up_message member
    message = "Thanks for signing up #{member.name}! "
    if member.roles.any?
      message << I18n.t("messages.member_notifications", roles: roles(member))
    else
      message << I18n.t("messages.no_roles")
    end
  end
end
