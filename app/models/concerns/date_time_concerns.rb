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

    def set_end_date_and_time
      new_end_date_and_time = datetime_from_fields(local_date, local_end_time)
      self.ends_at = new_end_date_and_time if new_end_date_and_time
    end

    def date
      I18n.l(date_and_time, format: :dashboard)
    end

    def time
      date_and_time&.time
    end

    # The timezone conversion is a pure function of the attribute value and
    # the chapter time zone, and views read these several times per request
    # (title, header, meta tags, actions partial), so memoize per instance.
    # The attribute writers invalidate the memo so any assignment path
    # (attribute writer, update, set_date_and_time) stays consistent.
    def date_and_time
      return @date_and_time if defined?(@date_and_time)

      @date_and_time = super&.in_time_zone(time_zone)
    end

    def ends_at
      return @ends_at if defined?(@ends_at)

      @ends_at = super&.in_time_zone(time_zone)
    end

    def date_and_time=(value)
      clear_datetime_memo
      super
    end

    def ends_at=(value)
      clear_datetime_memo
      super
    end

    def past?
      date_and_time < Time.zone.today
    end

    private

    def clear_datetime_memo
      remove_instance_variable(:@date_and_time) if defined?(@date_and_time)
      remove_instance_variable(:@ends_at) if defined?(@ends_at)
    end

    def datetime_from_fields(date_string, time_string)
      return nil if date_string.blank? || time_string.blank? || !time_zone

      date = Date.parse(date_string)
      time = Time.zone.parse(time_string)
      ActiveSupport::TimeZone[time_zone].local(date.year, date.month, date.day, time.hour, time.min)
    end
  end
end
