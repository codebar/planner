class TermsAndConditionsController < ApplicationController
  before_action :logged_in?

  def show
    @terms_and_conditions_form = TermsAndConditionsForm.new
  end

  def update
    @terms_and_conditions_form = TermsAndConditionsForm.new(terms_params)
    if @terms_and_conditions_form.valid?
      member = current_user
      member.update_attribute(:accepted_toc_at, Time.zone.now)
      redirect_to previous_path
    else
      flash[notice] = I18n.t('members.terms_and_conditions.messages.notice')
      render :show
    end
  end

  private

  def terms_params
    params.require(:terms_and_conditions_form).permit(:terms)
  end
end
