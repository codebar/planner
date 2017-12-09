class Admin::ChaptersController < Admin::ApplicationController
  before_action :set_chapter, only: [:show, :edit, :update]
  after_action :verify_authorized

  def new
    @chapter = Chapter.new
    authorize @chapter
  end

  def create
    @chapter = Chapter.new(chapter_params)
    authorize(@chapter)

    if @chapter.save
      flash[:notice] = "Chapter #{@chapter.name} has been successfully created"
      redirect_to [:admin, @chapter]
    else
      flash[:notice] = @chapter.errors.full_messages
      render 'new'
    end
  end

  def show
    authorize(@chapter)

    @workshops = @chapter.workshops.upcoming
    @sponsors = @chapter.sponsors.uniq
    @groups = @chapter.groups
    @subscribers = @chapter.subscriptions.last(20).reverse
  end

  def edit
    authorize @chapter
  end

  def update
    authorize(@chapter)

    if @chapter.update(chapter_params)
      flash[:notice] = "Chapter #{@chapter.name} has been successfully updated"
      redirect_to [:admin, @chapter]
    else
      flash[:notice] = @chapter.errors.full_messages
      render 'edit'
    end
  end

  def members
    chapter = Chapter.find(params[:chapter_id])
    authorize chapter
    type = params[:type]

    if ['students', 'coaches'].include?(type)
      @emails = chapter.send(type).map(&:email).join("\n")
    else
      @emails = chapter.members.pluck(:email).uniq.join("\n")
    end

    render plain: @emails
  end

  private

  def chapter_params
    params.require(:chapter).permit(:name, :email, :city, :time_zone, :twitter)
  end

  def set_chapter
    @chapter = Chapter.find(params[:id])
  end
end
