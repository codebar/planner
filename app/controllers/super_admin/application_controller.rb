class SuperAdmin::ApplicationController < ApplicationController
  include Pundit

  before_action :authenticate_admin!
end
