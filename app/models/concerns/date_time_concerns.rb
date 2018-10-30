module DateTimeConcerns
  extend ActiveSupport::Concern

  included do
    include InstanceMethods
  end

  module InstanceMethods
    delegate :future?, to: :date_and_time

    def set_date_and_time
      new_date_and_time = datetime_from_fields(local_date, local_time)
      self.date_and_time = new_date_and_time if new_date_and_time
    end

    def date
      I18n.l(date_and_time, format: :dashboard)
    end

    def time
      date_and_time.try(:time)
    end

    def date_and_time
      return nil unless super
      super.in_time_zone(time_zone)
    end

    def datetime_from_fields(date_string, time_string)
      return nil if date_string.blank? || time_string.blank? || !time_zone
      date = Date.parse(date_string)
      time = Time.zone.parse(time_string)
      ActiveSupport::TimeZone[time_zone].local(date.year, date.month, date.day, time.hour, time.min)
    end

    def past?
      date_and_time < Time.zone.today
    end
  end
end
