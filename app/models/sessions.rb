class Sessions < ActiveRecord::Base

    scope :upcoming, ->  { Sessions.where("date_and_time > ?",  DateTime.now) }
end
