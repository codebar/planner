class Admin::TestimonialsController < SuperAdmin::ApplicationController
  def index
    @testimonials = Testimonial.includes(:member).all

    authorize @testimonials
  end
end
