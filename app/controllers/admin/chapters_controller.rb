class Admin::ChaptersController < Admin::ApplicationController
  def new
    @chapter = Chapter.new
  end

  def create
    @chapter = Chapter.new(chapter_params)
    if @chapter.save
      flash[:notice] = "Chapter #{@chapter.name} has been succesfuly created"
      redirect_to [:admin, @chapter ]
    else
      flash[:notice] = @chapter.errors.full_messages
      render 'new'
    end
  end

  def show
    @chapter = Chapter.find(params[:id])
    @workshops = Sessions.upcoming
    @sponsors = Sponsor.all
    @groups = Group.all
  end

  private
  def chapter_params
    params.require(:chapter).permit(:name, :city)
  end
end
