class DonationsController < ApplicationController
  def new
    redirect_to I18n.t('services.donations'), allow_other_host: true
  end
end
