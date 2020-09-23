class DonationsController < ApplicationController
  def new
    redirect_to I18n.t('services.donations')
  end
end
