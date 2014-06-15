class Admin::ApplicationController < ApplicationController
  include Pundit

  before_action :has_permissions?

  private

  def has_permissions?
    redirect_to root_path unless manager?
  end
end
