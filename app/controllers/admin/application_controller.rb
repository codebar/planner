class Admin::ApplicationController < ApplicationController
  include Pundit

  before_action :has_access?

end
