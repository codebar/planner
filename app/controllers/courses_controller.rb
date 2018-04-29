class CoursesController < ApplicationController
  before_action :set_course

  def rsvp
    invitation = CourseInvitation.find_or_create_by(course: @course, member: current_user)
    redirect_to course_invitation_path(invitation)
  end

  def show
    @host_address = AddressPresenter.new(@course.sponsor.address)
    @course = CoursePresenter.new(@course)
  end

  private

  def set_course
    slug = params[:id] || params[:course_id]
    @course = Course.find_by(slug: slug)
  end
end
