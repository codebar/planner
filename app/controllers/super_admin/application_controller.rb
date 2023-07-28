class SuperAdmin::ApplicationController < ApplicationController
  include Pundit::Authorization

  before_action :authenticate_admin!
end
