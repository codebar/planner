class WorkshopPresenter < SimpleDelegator

  def attendees_csv
    CSV.generate {|csv| attendee_array.each { |a| csv << a } }
  end

  private

  def attendee_array
    model.attendances.map {|i| [i.member.full_name, i.role.upcase] }
  end

  def model
    __getobj__
  end
end
