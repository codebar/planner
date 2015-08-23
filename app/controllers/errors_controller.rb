class ErrorsController < ApplicationController
  def error404
    render status: :not_found
  end

  def error500
    render status: :internal_error
  end
end
