class Admin::SponsorsController < Admin::ApplicationController

  before_filter :set_sponsor, only: [ :show, :edit, :update]

  def index
    authenticate_admin_or_organiser!
    @sponsors = Sponsor.all.order(:name)
  end

  def new
    @sponsor = Sponsor.new
    @sponsor.build_address
    @sponsor.contacts.build
    authorize @sponsor
  end

  def create
    @sponsor = Sponsor.new(sponsor_params)
    @sponsor.build_address unless @sponsor.address.present?
    authorize @sponsor
    if @sponsor.save
      redirect_to admin_sponsors_path, notice: "Sponsor #{@sponsor.name} created"
    else
      flash[:notice] = @sponsor.errors.full_messages.to_s
      render :new
    end
  end

  def edit
    @sponsor = Sponsor.find(params[:id])
    authorize @sponsor
    @sponsor.build_address unless @sponsor.address.present?
    @sponsor.contacts.build
  end

  def update
    if (@sponsor.update_attributes(sponsor_params))
      redirect_to admin_sponsors_path, notice: "Sponsor #{@sponsor.name} updated"
    else
      render :edit
    end
  end

  private
  def sponsor_params
    params.require(:sponsor).permit(:name, :avatar, :website, :seats, :number_of_coaches, 
      :email, :contact_first_name, :contact_surname, contact_ids: [],
      address_attributes: [:flat, :street, :postal_code, :city, :latitude, :longitude, :accessible, :note])
  end

  def set_sponsor
    @sponsor = Sponsor.find(params[:id])
    authorize @sponsor
  end
end
