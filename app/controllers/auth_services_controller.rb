class AuthServicesController < ApplicationController
  def new
    referer_path = URI(request.referer).path if request.referer
    if Rails.application.routes.recognize_path(referer_path)[:controller].in?(%w[workshops events meetings])
      session[:referer_path] = referer_path
    end
    redirect_to '/auth/github'
  end

  def create
    member_type = cookies[:member_type]
    current_service = AuthService.find_by(provider: omnihash[:provider],
                                          uid: omnihash[:uid])

    if logged_in?
      if current_service
        flash[:notice] = I18n.t('notifications.provider_already_connected',
                                provider: omnihash[:provider])
      end
      redirect_to root_path
    elsif current_service
      session[:member_id] = current_service.member.id
      session[:service_id]         = current_service.id
      session[:oauth_token]        = omnihash[:credentials][:token]
      session[:oauth_token_secret] = omnihash[:credentials][:secret]

      finish_registration || redirect_to(referer_or_dashboard_path)
    else
        email = omnihash[:info][:email].to_s.strip

        if email.blank?
          flash[:error] = I18n.t('notifications.email_missing_from_provider')
          return redirect_to root_url
        end

        member = Member.find_by(email:)
        member ||= Member.new(email:)

        member.name    ||= omnihash[:info][:name]&.split(' ')&.first || ''
        member.surname ||= omnihash[:info][:name]&.split(' ')&.drop(1)&.join(' ') || ''

        member_service = member.auth_services.build(
          provider: omnihash[:provider],
          uid: omnihash[:uid]
        )

        member.save!

        # Set, not Toggle: toggling would flip can_log_in off for a member who
        # links a second auth service. Skip the conditional profile validations
        # here on purpose — a brand-new member completes name/about_you on the
        # next (details) page, and running them now aborts the signup callback.
        member.update_column(:can_log_in, true) # rubocop:disable Rails/SkipsModelValidations

        session[:member_id]          = member.id
        session[:service_id]         = member_service.id
        session[:oauth_token]        = omnihash[:credentials][:token]
        session[:oauth_token_secret] = omnihash[:credentials][:secret]

        redirect_to edit_member_details_path(member_type: member_type)
    end
  end

  def destroy
    service = current_user.services.find(params[:id])
    if service.respond_to?(:destroy) && service.destroy
      flash[:notice] = I18n.t('notifications.provider_unlinked',
                              provider: service.provider)
      redirect_to redirect_path
    end
  end

  def failure
    flash[:error] = I18n.t('notifications.authentication_error')
    redirect_to root_url
  end

  private

  def referer_or_dashboard_path
    session[:referer_path] || dashboard_path
  end

  def omnihash
    request.env['omniauth.auth']
  end

  def omniauth_providers
    (OmniAuth::Strategies.local_constants.map(&:downcase) - %i[developer oauth oauth2]).map(&:to_s)
  end

  def redirect_path
    :services
  end
end
