class WorkshopPresenter < EventPresenter

  def venue
    model.host
  end

  def attendees_csv
    CSV.generate {|csv| attendee_array.each { |a| csv << a } }
  end

  def time
    I18n.l(model.time, format: :time)
  end

  def path
    Rails.application.routes.url_helpers.chapter_path(model.chapter.name.downcase)
    Rails.application.routes.url_helpers.workshop_path model
  end

  private

  def attendee_array
    model.attendances.map {|i| [i.member.full_name, i.role.upcase] }
  end

  def model
    __getobj__
  end
end
