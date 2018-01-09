class CoursesController < ApplicationController
  before_action :set_course

  def rsvp
    invitation = CourseInvitation.where(course: @course, member: current_user).first_or_create
    redirect_to course_invitation_path(invitation)
  end

  def show
    @host_address = AddressDecorator.decorate(@course.sponsor.address)
    @course = CoursePresenter.new(@course)
  end

  private

  def set_course
    slug = params[:id] || params[:course_id]
    @course = Course.find_by_slug(slug)
  end
end
