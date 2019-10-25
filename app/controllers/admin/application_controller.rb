class Admin::ApplicationController < ApplicationController
  include Pundit

  before_action :authenticate_admin_or_organiser!
end
