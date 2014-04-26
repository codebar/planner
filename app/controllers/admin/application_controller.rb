class Admin::ApplicationController < ApplicationController
  before_action :is_admin?

  def is_admin?
    redirect_to root_path unless logged_in? and current_member.is_admin?
  end

end
