module Admin::WorkshopConcerns
  extend ActiveSupport::Concern

  included do
    include InstanceMethods
  end

  module InstanceMethods
    def set_admin_workshop_data
      @attending_students = InvitationPresenter.decorate_collection(@workshop.attending_students.all)
      @attending_coaches = InvitationPresenter.decorate_collection(@workshop.attending_coaches.all)
      @coach_waiting_list = WaitingListPresenter.new(WaitingList.by_workshop(@workshop)
                                                .where_role('Coach')
                                                .order(:created_at))
      @student_waiting_list = WaitingListPresenter.new(WaitingList.by_workshop(@workshop)
                                                  .where_role('Student')
                                                  .order(:created_at))
    end

    private

    def set_workshop
      @workshop = Workshop.find(params[:workshop_id])
    end
  end
end
