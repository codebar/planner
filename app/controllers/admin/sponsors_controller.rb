class Admin::SponsorsController < Admin::ApplicationController
  before_action :set_sponsor, only: %i[show edit update]

  def index
    authorize Sponsor
    @sponsors = Sponsor.all.reorder('lower(name)').paginate(page: page)
    @decorated_sponsors = SponsorPresenter.decorate_collection(@sponsors)
  end

  def show
    @sponsor = SponsorPresenter.new(@sponsor)
  end

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
      return redirect_to [:admin, @sponsor]
    end

    flash[:warning] = @sponsor.errors.full_messages
    render 'new'
  end

  def edit
    @sponsor = Sponsor.find(params[:id])
    authorize @sponsor
    @sponsor.build_address if @sponsor.address.blank?
    @sponsor.contacts.build unless @sponsor.contacts.any?
  end

  def update
    @sponsor.assign_attributes(sponsor_params)

    if @sponsor.valid? && @sponsor.save
      flash[:notice] = 'Updated!'
      return redirect_to admin_sponsor_path(@sponsor)
    end

    flash[:warning] = @sponsor.errors.full_messages
    render 'edit'
  end

  private

  def sponsor_params
    params.require(:sponsor).permit(:name, :avatar, :website, :seats, :accessibility_info,
                                    :number_of_coaches, :level,
                                    address_attributes: %i[id flat street postal_code city latitude longitude directions],
                                    contacts_attributes: %i[id name surname email mailing_list_consent _destroy])
  end

  def set_sponsor
    @sponsor = Sponsor.find(params[:id])
    authorize @sponsor
  end

  def page
    params.permit(:page)[:page]
  end
end
