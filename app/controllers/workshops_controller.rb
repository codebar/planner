class WorkshopsController < ApplicationController
  before_action :authenticate_member!, except: [:show]
  before_action :set_workshop, only: %i[show rsvp]

  def show
    # Mirrors the venue/sponsors/organisers fragment keys: those records mutate
    # without touching workshops.updated_at, so a host/address/sponsor/organiser
    # change must rotate the etag or anonymous repeat visits get stale 304s.
    # address lives on the host sponsor for in-person workshops; virtual
    # workshops have no host.
    unless logged_in?
      fresh_when(@workshop,
                 etag: [@workshop, @workshop.host, @workshop.host&.address,
                        @workshop.sponsors, @workshop.organisers, I18n.locale, :v1])
      # fresh_when renders a 304 without halting, and the virtual render below
      # would raise DoubleRenderError on top of it.
      return if performed?
    end

    @workshop = WorkshopPresenter.decorate(@workshop)

    render 'virtual_workshops/show' if @workshop.virtual?
  end

  def rsvp
    unless @workshop.available_for_rsvp?
      return redirect_back(
        fallback_location: root_path,
        notice: t('workshops.registration_not_open')
      )
    end

    if role_params.nil?
      @invitation = find_attending_invitation(@workshop, current_user)
    else
      if user_attending_or_waitlisted?(@workshop, current_user)
        return redirect_back fallback_location: root_path, notice: t('workshops.already_wish_to_attend')
      end

      @invitation = find_or_create_invitation(@workshop, current_user, role_params)
    end

    redirect_to invitation_path(@invitation)
  end

  private

  def set_workshop
    @workshop = Workshop.find(params[:id])
  end

  def role_params
    params[:role]
  end

  def find_attending_invitation(workshop, user)
    WorkshopInvitation.find_by(workshop:, member: user, attending: true)
  end

  def find_or_create_invitation(workshop, user, role)
    # Identity is workshop + member, matching InvitationManager; the member's
    # role choice wins, so an existing invitation with the other role is updated.
    invitation = WorkshopInvitation.find_or_create_by!(workshop:, member: user) { |record| record.role = role }
    invitation.update!(role:) unless invitation.role.eql?(role)
    invitation
  rescue ActiveRecord::RecordNotUnique
    WorkshopInvitation.find_by(workshop:, member: user)
  end

  def user_attending_or_waitlisted?(workshop, user)
    workshop.attendee?(user) || workshop.waitlisted?(user)
  end
end
