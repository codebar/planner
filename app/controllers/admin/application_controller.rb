class Admin::ApplicationController < ApplicationController
  include Pundit::Authorization

  before_action :authenticate_admin_or_organiser!
end
