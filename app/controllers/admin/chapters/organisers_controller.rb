class Admin::Chapters::OrganisersController < Admin::ApplicationController
  before_action :set_chapter, only: %i[index create destroy]
  after_action :verify_authorized

  def index
    authorize :organiser

    @organisers = @chapter.organisers
    @chapter_members = @chapter.members
  end

  def create
    authorize :organiser

    member = Member.find(params[:organiser][:organiser])
    member.add_role(:organiser, @chapter)

    redirect_to admin_chapter_organisers_path(@chapter), notice: 'Successfully added organiser.'
  end

  def destroy
    authorize :organiser

    member = Member.find(params[:id])

    member.remove_role(:organiser, @chapter)
    redirect_to admin_chapter_organisers_path(@chapter), notice: 'Successfully removed organiser.'
  end

  private

  def set_chapter
    @chapter = Chapter.find(params[:chapter_id])
  end
end
