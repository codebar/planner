class Admin::SponsorsController < Admin::ApplicationController
  before_action :set_sponsor, only: %i[show edit update]

  def index
    authorize Sponsor
    @sponsors = Sponsor.all.order(:name)
  end

  def show; end

  def new
    @sponsor = Sponsor.new
    @sponsor.build_address
    @sponsor.contacts.build
    authorize @sponsor
  end

  def create
    @sponsor = Sponsor.new(sponsor_params)
    @sponsor.build_address if @sponsor.address.blank?
    authorize @sponsor

    if @sponsor.valid? && @sponsor.save
      flash[:notice] = "Sponsor #{@sponsor.name} created"
      redirect_to [:admin, @sponsor]
    else
      flash[:warning] = @sponsor.errors.full_messages
      render 'new'
    end
  end

  def edit
    @sponsor = Sponsor.find(params[:id])
    authorize @sponsor
    @sponsor.build_address if @sponsor.address.blank?
    @sponsor.contacts.build
  end

  def update
    @sponsor.update(sponsor_params)
    redirect_to admin_sponsor_path(@sponsor), notice: 'Updated!'
  end

  private

  def sponsor_params
    params.require(:sponsor).permit(:name, :avatar, :website, :seats, :accessibility_info,
                                    :number_of_coaches, :level, :email, :contact_first_name,
                                    :contact_surname, member_ids: [], address_attributes:
                                    %i[flat street postal_code city latitude longitude directions])
  end

  def set_sponsor
    @sponsor = Sponsor.find(params[:id])
    authorize @sponsor
  end
end
