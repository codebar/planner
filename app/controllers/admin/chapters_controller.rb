class Admin::ChaptersController < Admin::ApplicationController
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
      redirect_to [:admin, @chapter ]
    else
      flash[:notice] = @chapter.errors.full_messages
      render 'new'
    end
  end

  def show
    @chapter = Chapter.find(params[:id])
    authorize(@chapter)

    @workshops = @chapter.workshops.upcoming
    @sponsors = @chapter.sponsors.uniq
    @groups = @chapter.groups
    @subscribers = @chapter.subscriptions.last(20).reverse
  end

  private

  def chapter_params
    params.require(:chapter).permit(:name, :email, :city)
  end
end
