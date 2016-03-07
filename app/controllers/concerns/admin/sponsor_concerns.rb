module Admin::SponsorConcerns
  extend ActiveSupport::Concern

  included do
    before_action :set_workshop, only: [ :sponsor, :destroy_sponsor, :host, :destroy_host ]
    before_action :set_sponsor, only: [ :sponsor, :host ]

    include InstanceMethods
  end

  module InstanceMethods
    def sponsor
      if sponsor_session.save
        flash[:notice] = "Sponsor added successfully"
      else
        flash[:notice] = sponsor_session.errors.full_messages.to_s
      end
      redirect_to :back
    end

    def destroy_sponsor
      @sponsor = Sponsor.find(params[:sponsor_id])
      @workshop.sponsor_sessions.where(sponsor: @sponsor).first.delete
      redirect_to :back
    end

    def host
      set_sponsor
      @sponsor_session = SponsorSession.where(workshop: @workshop, sponsor: @sponsor).first_or_create
      @sponsor_session.update_attribute(:host, true)
      flash[:notice] = "Host set successfully"

      redirect_to :back
    end

    def destroy_host
      @workshop.sponsor_sessions.where(host: true).first.update_attribute(:host, false)

      redirect_to :back
    end

    private

    def set_workshop
      @workshop = Workshop.find(params[:workshop_id])
    end

    def set_sponsor
      @sponsor = Sponsor.find(params[:workshop][:sponsor_ids])
    end

    def sponsor_session(host=false)
      @sponsor_session ||= SponsorSession.new(workshop: @workshop, sponsor: @sponsor, host: host)
    end

  end
end
