class TermsAndConditionsController < ApplicationController
  # Skip accept_terms (from ApplicationController) to avoid an infinite redirect loop:
  # - If user hasn't accepted T&C, ApplicationController already redirects here
  # - If user has accepted, there's no reason to redirect away from this page
  # The view handles both cases (needs to accept vs already accepted)
  skip_before_action :accept_terms

  def show
    @terms_and_conditions_form = TermsAndConditionsForm.new
  end

  def update
    @terms_and_conditions_form = TermsAndConditionsForm.new(terms_params)
    if @terms_and_conditions_form.valid?
      member = current_user
      member.accepted_toc_at = Time.zone.now
      member.save(validate: false)
      redirect_to previous_path
    else
      flash[notice] = I18n.t('terms_and_conditions.messages.notice')
      render :show
    end
  end

  private

  def terms_params
    params.expect(terms_and_conditions_form: [:terms])
  end
end
