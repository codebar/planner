module Admin::SponsorConcerns
  extend ActiveSupport::Concern

  included do
    before_action :set_workshop, only: %i[sponsor destroy_sponsor host destroy_host]
    before_action :set_sponsor, only: %i[sponsor host]

    include InstanceMethods
  end

  module InstanceMethods
    def sponsor
      if workshop_sponsors.save
        flash[:notice] = 'Sponsor added successfully'
      else
        flash[:notice] = workshop_sponsors.errors.full_messages.to_s
      end
      redirect_to :back
    end

    def destroy_sponsor
      @sponsor = Sponsor.find(params[:sponsor_id])
      @workshop.workshop_sponsors.find_by(sponsor: @sponsor).destroy
      redirect_to :back
    end

    def host
      set_sponsor
      @workshop_sponsor = WorkshopSponsor.find_or_create_by(workshop: @workshop, sponsor: @sponsor)
      @workshop_sponsor.update_attribute(:host, true)
      flash[:notice] = 'Host set successfully'

      redirect_to :back
    end

    def destroy_host
      @workshop.workshop_sponsors.find_by(host: true).update_attribute(:host, false)

      redirect_to :back
    end

    private

    def set_workshop
      @workshop = Workshop.find(params[:workshop_id])
    end

    def set_sponsor
      @sponsor = Sponsor.find(params[:workshop][:sponsor_ids])
    end

    def workshop_sponsor(host = false)
      @workshop_sponsor ||= WorkshopSponsor.new(workshop: @workshop, sponsor: @sponsor, host: host)
    end
  end
end
