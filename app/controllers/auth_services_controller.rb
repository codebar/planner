class AuthServicesController < ApplicationController
  def create
    member_type = cookies[:member_type]
    current_service = AuthService.where(provider: omnihash[:provider],
                                        uid: omnihash[:uid]).first

    if logged_in?
      if current_service
        flash[:notice] = I18n.t('notifications.provider_already_connected',
                                provider: omnihash[:provider])
      end
      redirect_to root_path
    else
      if current_service
        session[:member_id]          = current_service.member.id
        session[:service_id]         = current_service.id
        session[:oauth_token]        = omnihash[:credentials][:token]
        session[:oauth_token_secret] = omnihash[:credentials][:secret]

        finish_registration or redirect_to dashboard_path
      else
        member = Member.find_by_email(omnihash[:info][:email])
        member = Member.new(email: (omnihash[:info][:email])) if member.nil?

        member.name    ||= omnihash[:info][:name].split(" ").first rescue("")
        member.surname ||= omnihash[:info][:name].split(" ").drop(1).join(" ") rescue("")
        member.twitter ||= omnihash[:info][:nickname]

        member_service = member.auth_services.build({
          provider: omnihash[:provider],
          uid: omnihash[:uid]
        })

        member.save!

        member.toggle!(:can_log_in)

        session[:member_id]          = member.id
        session[:service_id]         = member_service.id
        session[:oauth_token]        = omnihash[:credentials][:token]
        session[:oauth_token_secret] = omnihash[:credentials][:secret]

        redirect_to step1_member_path(member_type: member_type), notice: 'Thanks for signing up. Please fill in your details to complete the registration process.'
      end
    end
  end

  def destroy
    service = current_user.services.find(params[:id])
    if service.respond_to?(:destroy) and service.destroy
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

  def omnihash
    request.env['omniauth.auth']
  end

  def omniauth_providers
    (OmniAuth::Strategies.local_constants.map(&:downcase) - %i(developer oauth oauth2)).map(&:to_s)
  end

  def redirect_path
    :services
  end
end
